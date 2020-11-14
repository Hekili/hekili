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

    spec:RegisterPack( "Elemental", 20201113, [[dOu5mbqikrpIsO2Ke6tsvjzusKoLKWQKa8kkPMLe0TKaQDrXVOKmmPchdsAzss9mjrnnjqxJsqBtseFJsigNeqoNuvyDsvj18Kk6EOs7tQQoiLqQfIk6HsvjmrjrcDrPQOnkjsWhLej1jLePwPuLzkjsu3KsiXoHe)usKKLkjsKNQstfv4QsvjQTkvLiFLsij7fXFfAWcomvlgupMOjdXLv2Su(mQA0uQtd8AjQzRQBRIDl63OmCj1XPey5eEoutN01bz7sL(UKKXtjKuNxIy9svPMpKA)inbvchKlIRJGs1DuDhOIkQf00rFGAFuWktUAj1JCRDzzNFKB6NrU95VZs1FYT2l5zocHdYfZGeYrU2QwJ7RTYkEGAdbBKSJvyWb6DfWsPWBQvyWrAf5cdbETsNeyYfX1rqP6oQUdurf1cA6OpqTpQSfHCX1tsqP6kPAY1gGGSKatUidljxlMg6ZFNLQ)0W12pEs7zX0akSU7apbnGALlKgQUJQ7G2J2ZIPH(cBp5hUVM2ZIPHcmnyrJGmeAa2LLHQPH(eJxkhn4WGhOLyO9SyAOatdCu18YyAqz0a4ulyDhn0NsBgi5PHRntwMgQNGgQ0YskW9LgiX0apeazgYTwWAGFKRftd95VZs1FA4A7hpP9SyAafw3DGNGgqTYfsdv3r1Dq7r7zX0qFHTN8d3xt7zX0qbMgSOrqgcna7YYq10qFIXlLJgCyWd0sm0EwmnuGPboQAEzmnOmAaCQfSUJg6tPndK80W1Mjltd1tqdvAzjf4(sdKyAGhcGmdThTNlvalXMAXKSdSRCHWlc0Dkm9Z469n22foo2yPgzTynRQjO9CPcyj2ulMKDGD1AUwvZualP9O9SyAOpTOEsiDi0W6orj0GcoJgu7rdUuzcAaGPbVRdEh(NH2ZIPH(chR0aNpJH8qyLgoEc5)xcnaA0GApAWIUVNaOJg4q4aLgSOt5WQWFAOsPHzPNYrdamnulgEPAO9CPcyjMl8Zyipewle04699eaDgpLdRc)JIHzPNYzw6W)qO9SyAOsNfyj7a7knuZualPbaMgQfRnXsf4)xcn8GS8qObLrdQ9OHk1qUab4jnWA0GfDFpbtTlKgGYFymnizhyxPHQa)tdlrObSntOFjgApxQawITMRv1mfWYcbnUnaVTgf74Ge3zL0bA0sg7ryvLgEixGa8mYArVVNGP2gXooiXDw5oO9O9SyAOsN6ecOALgynAq6yfBO9CPcyj2AUwvfirIy75cApxQawITMRvq4fb6oyApxQawITMRvnGyX97Su9N2ZLkGLyR5AfwzItC)olv)P9O9CPcyj2AUwjzPCPkCDiX27Nr75sfWsS1CTc(zmKiRfv7fxUtj0EUubSeBnxR4HCbcWZiRf9(EcMAt75sfWsS1CTQXKq4He9(EcGUi88dTNlvalXwZ1QAibOvci5JWVJvApxQawITMRvQ9IqjmdkrInMqoApxQawITMRvNDyIsISw8HKaKiIy(bt75sfWsS1CTsaQR)fbzex7Yr75sfWsS1CTQkM4r6oqgfdZspLJ2ZLkGLyR5ALyEni5JT3pdxiOXvDb)uJ98xTJ1sT)cuhOrRUGFQXE(R2XAP2z1DGgDdWBRrXooiXDw5oO9SyAOsN0G0XJgQ00qJj4zknGzNP2GK3q75sfWsS1CTYEUqJdJxkhThTNlvalXwZ1k4NXqInirjfcACTu9FPACSCjINYzw6W)qqJggQ1mowUeXt5mq1OrlzShHvvACSCjINYze74Ge3Vf2bTNlvalXwZ1k4jWtugK8fcACTu9FPACSCjINYzw6W)qqJggQ1mowUeXt5mq10EUubSeBnxRAaXGFgdPqqJRLQ)lvJJLlr8uoZsh(hcA0WqTMXXYLiEkNbQgnAjJ9iSQsJJLlr8uoJyhhK4(TWoO9CPcyj2AUw5PCyv4Fu6)xiOX1s1)LQXXYLiEkNzPd)dbnAyOwZ4y5sepLZavJgTKXEewvPXXYLiEkNrSJdsC)wyh0EUubSeBnxRGD(iRfvbqwgxiOX1s1)LQXXYLiEkNzPd)dbnAlHHAnJJLlr8uodunThTNlvalXwZ1QAb4Weia)Jv5DxHYsK)IQl4NI5IAHGgxlHHAntTaCyceG)XQ8UZavt75sfWsS1CTQ7W1tevMUdTNlvalXwZ1QMVOk8e3GWaws7r75sfWsS1CTAsBgi5JyBMSCHGg3sp(ESkyN(5wjDGgTKXEewvP59UEegsGvJyhhK4o5YlrqJggQ1mV31Jyib)mq1vq75sfWsS1CTsaLrxQawgFawlm9Z46SviOX1LkO7Il3bmC)vxSuC9(pQUGFk2iTDqgFaVTMGKV)QrJgxV)JQl4NInV31JWZp9xDf0EUubSeBnxReqz0LkGLXhG1ct)mUyqY)lQUGFkThTNlvalXgNnUsBhKrBx0DyL2ZLkGLyJZM1CTcRmXP8w9efcACv)xQgSYeNYB1tyw6W)qO9SyA4wlMJqdvk8(z0W1MjltdGKg6KlnuqAqDb)uAOb4TvCH0amKsdjtPbeibi5PHBFsdq1k4ScHYFymnucdQVsmAOb4TvqYtdvMguxWpftdEIqd2E3rd)WyAqT9KgqTG0GfvGeHgQudHvAaRUSm2q75sfWsSXzZAUw1E)Si2MjlxOSe5VO6c(PyUOwiOXvSMyyBh(xXsX17)O6c(PyJ02bz8b82Acs(oTq0OTSEQbRmXjUFNLQ)gxQGUdnAC9(pQUGFk2iTDqgFaVTMGKNBLlcd1AMQajsKhcRgS6YYDIAbRG2ZLkGLyJZM1CTAsBgi5JyBMSCHGgx1)LQzsBgi5JyBMSSzPd)dH2ZLkGLyJZM1CTsA7Gm(aEBnbjFHGgxyOwZGvM4uEREcduDryOwZmPndK8rSntw2avt75sfWsSXzZAUwnxO2waKxEfcACHHAnZK2mqYhX2mzzduDrjJ9iSQsdwzIt5T6jmIDCqI7hgQ1mtAZajFeBZKLnIDCqITU6cGxIq75sfWsSXzZAUw5y5sepLRqqJR6)s14y5sepLZS0H)HuSulRNAWktCI73zP6VXLkO7QOyPwQ(Vuna5AqIsmlD4FiOrBjmuRzaY1GeLyGQlAPKXEewvPbixdsuIbQUcApxQawInoBwZ1QhybqaK4X5pEuz6ofcACv)xQMhybqaK4X5pEuz6oMLo8peApxQawInoBwZ1Q376ryibwle04Q(VunhhRtezTOAV4(DwQyZsh(hsXJVhRc2PFUwyhfHHAnZ7D9igsWpdunTNlvalXgNnR5A1K2mqYhX2mz5cbnUQ)lvZK2mqYhX2mzzZsh(hcTNlvalXgNnR5A1CHABbqE5r75sfWsSXzZAUwnxO2rSntwUqqJRakxJj4NzsB2WrwlYlMRrmuImbi5nZcGa11dPOLWqTMzsB2WrwlYlMRrmuImbi5nq1flv9FPAoowNiYAr1EX97SuXMLo8pe0OHHAnZXX6erwlQ2lUFNLk2avJgnUE)hvxWpfBK2oiJpG3wtqY3FLRG2ZIPboeLqdkJg49ZOH(0fQTfa5LhnufqTPblkowNGgynAqThn0N)olvmnad1A0qv2lPHgG3wbjpnuzAqDb)uSHgQuKL9vknW6oH0RPblk(ESkyhlP9CPcyj24SznxRMluBlaYlVcbnUwQ(VunhhRtezTOAV4(DwQyZsh(hcA0WqTMbRmXP8w9egOA0Op(ESkyN(5wkQD0rbUGfaUE)hvxWpfBK2oiJpG3wtqYxbA0WqTM54yDIiRfv7f3VZsfBGQrJgxV)JQl4NInsBhKXhWBRji57VY0EwmnyrXlpAadjgnucdIgqyzFLsdpdpAWPHRYeNYB1tqdWqTMH2ZLkGLyJZM1CTsA7Gm(aEBnbjFHGgxyOwZGvM4uEREcJyhhK4oRCbWlrkayOwZGvM4uEREcdwDzzAplMgQuLFj0G0XknuPS31PboHeyLgyjnO2InAqDb)umnaA0aqPbaMg8Kgajw9uPbprOHRYehAOp)DwQ(tdamnGsLkoObxQGUZq75sfWsSXzZAUw9ExpcdjWAHGgxyOwZ8ExpIHe8ZavxexV)JQl4NInsBhKXhWBRji57SGfl1Y6PgSYeN4(DwQ(BCPc6UkkIWut79ZIyBMSSrbYYGKN2ZLkGLyJZM1CTcixdsusHGgxC9(pQUGFk2iTDqgFaVTMGKVZcw0syOwZ4y5sepLZavt75sfWsSXzZAUw1emSgX2mz5cbnU469FuDb)uSrA7Gm(aEBnbjFNfSimuRzaY1GeLyGQlAjmuRzCSCjINYzGQP9SyAOVmE0qF(7Su9Ng48DSsdoVdsSsdq10GYOHktdQl4NIPbhtdpl5PbhtdxLjo0qF(7Su9NgayAizkn4sf0DgApxQawInoBwZ1Q97Su9pc)owle04Q(Vun73zP6Fe(DSAw6W)qkIR3)r1f8tXgPTdY4d4T1eK8DwWILAz9udwzItC)olv)nUubDxf0EUubSeBC2SMRvsBhKXhWBRji5P9CPcyj24SznxREVRhHHeyTWdRli55IAHGgxyOwZ8ExpIHe8ZavxuYypcRQmkMlvApxQawInoBwZ1Q27NfX2mz5cpSUGKNlQfklr(lQUGFkMlQfcACfRjg22H)r75sfWsSXzZAUw1emSgX2mz5cpSUGKNlQ0E0EUubSeBWGK)xuDb)uUT3plITzYYfklr(lQUGFkMlQfcACl1sfildsE0OryQP9(zrSntw2i2XbjUtU8se0Ov)xQghlxI4PCMLo8pKIim10E)Si2MjlBe74Ge3zPsg7ryvLghlxI4PCgXooiXwdd1AghlxI4PCgeiHRawwrrjJ9iSQsJJLlr8uoJyhhK4olyXsTu9FPAWktCI73zP6VzPd)dbnA1)LQbRmXjUFNLQ)MLo8pKIsg7ryvLgSYeN4(DwQ(Be74Ge3jQv3rfvuSuyOwZufirI8qy1GvxwUtuliA0WqTM59UEedj4NbQgnAlHHAnd8Zyipewnq1vq75sfWsSbds(Fr1f8tTMRvowUeXt5ke04Q(VunowUeXt5mlD4FiflvbN1p3kPd0OHHAnd8Zyipewnq1vuuYypcRQ08ExpcdjWQrSJdsC)DuSulRNAWktCI73zP6VXLkO7qJ2s1)LQbRmXjUFNLQ)MLo8pKkkwQLQ)lvdqUgKOeZsh(hcA0wcd1AgGCnirjgO6IwkzShHvvAaY1GeLyGQRG2ZLkGLydgK8)IQl4NAnxR2VZs1)i87yTqqJR6)s1SFNLQ)r43XQzPd)dPyPQ)lvZXX6erwlQ2lUFNLk2S0H)HuSuyOwZCCSorK1IQ9I73zPInq1fp(ESkyNoRKoqJ2syOwZCCSorK1IQ9I73zPInq1vGgTLQ)lvZXX6erwlQ2lUFNLk2S0H)HurXsTS06PgSYeN4(DwQ(BCPc6UIQ)lvdwzItC)olv)nlD4FivuegQ1mvbsKipewny1LL7e1cwbTNlvalXgmi5)fvxWp1AUwHvM4uEREIcbnUQ)lvdwzIt5T6jmlD4Fiflv4aK46Uunocc2izqP2zLrJw4aK46Uunocc2aY(TWoQOyPhFpwfStNfSGvq75sfWsSbds(Fr1f8tTMRvtAZajFeBZKLle04Q(VuntAZajFeBZKLnlD4FifLm2JWQknV31JWqcSAe74Ge3j3oO9CPcyj2Gbj)VO6c(PwZ1Q376ryibwle04Q(VuntAZajFeBZKLnlD4FifHHAnZK2mqYhX2mzzdunTNlvalXgmi5)fvxWp1AUw9alacGepo)XJkt3PqqJR6)s18alacGepo)XJkt3XS0H)Hq75sfWsSbds(Fr1f8tTMRvpG3wtqYhHzVwiOXfgQ1myLjoL3QNWavxexV)JQl4NInsBhKXhWBRji57S6ILcd1AMJJ1jISwuTxC)olvSbQUcApxQawInyqY)lQUGFQ1CTAUqTTaiV8ke04cd1AMjTzdhzTiVyUgXqjYeGK3avxSulv)xQMJJ1jISwuTxC)olvSzPd)dbnAyOwZCCSorK1IQ9I73zPInq1vq75sfWsSbds(Fr1f8tTMRvZfQTfa5LxHGg3sX17)O6c(PyJ02bz8b82Acs((rTIILAjctnT3plITzYYgXAIHTD4FOrxp1GvM4e3VZs1FJlvq3vrXsTu9FPAoowNiYAr1EX97SuXMLo8pe0OHHAnZXX6erwlQ2lUFNLk2avJgTKXEewvP59UEegsGvJyhhK4(7O4X3Jvb70p3(O6kO9CPcyj2Gbj)VO6c(PwZ1Q5c1oITzYYfcACv)xQMJJ1jISwuTxC)olvSzPd)dPyPWqTM54yDIiRfv7f3VZsfBGQrJwYypcRQ08ExpcdjWQrSJdsC)Du847XQGD6NBFunA0469FuDb)uSrA7Gm(aEBnbjFNvxSimuRzWktCkVvpHbQUOKXEewvP59UEegsGvJyhhK4o5YlrQG2ZLkGLydgK8)IQl4NAnxREaVTMGKpcZETqqJB9udwzItC)olv)nUubDxr1)LQbRmXjUFNLQ)MLo8pKILAjmuRzEVRhXqc(zGQlcd1Ag4NXqEiSAGQRG2ZLkGLydgK8)IQl4NAnxREaVTMGKpcZETqqJBPWqTMbRmXP8w9egXooiXDIQb1cGxIuaWqTMbRmXP8w9egS6YYOrdd1AgSYeNYB1tyGQlcd1AMJJ1jISwuTxC)olvSbQUcApxQawInyqY)lQUGFQ1CTQjyynITzYYfcACv)xQgGCnirjMLo8pKIQ)lvZXX6erwlQ2lUFNLk2S0H)HuegQ1ma5AqIsmq1fHHAnZXX6erwlQ2lUFNLk2avt75sfWsSbds(Fr1f8tTMRvV31JWqcSwiOXfgQ1mowUeXt5mq10EUubSeBWGK)xuDb)uR5A17D9imKaRfcACLm2JWQkJI5sTOLQ)lvZXX6erwlQ2lUFNLk2S0H)Hq75sfWsSbds(Fr1f8tTMRva5AqIske04Q(Vuna5AqIsmlD4FifTS0JVhRc2PFlIfwuYypcRQ08ExpcdjWQrSJdsCNC7OIILAP6)s1GvM4e3VZs1FZsh(hcA0wwp1GvM4e3VZs1FJlvq3vbTNlvalXgmi5)fvxWp1AUw9ExpcdjWAHGgxjJ9iSQYOyUulkTDb)W9R(VuntAZISwuTxC)olvSzPd)dH2ZLkGLydgK8)IQl4NAnxRAcgwJyBMSCHGgx1)LQbixdsuIzPd)dPimuRzaY1GeLyGQlcd1AgGCnirjgXooiXDIQb1cGxIuaWqTMbixdsuIbRUSmTNlvalXgmi5)fvxWp1AUw9ExpcdjWAHGgxjJ9iSQYOyUuP9CPcyj2Gbj)VO6c(PwZ1Q27NfX2mz5cLLi)fvxWpfZf1cbnUI1edB7W)O9CPcyj2Gbj)VO6c(PwZ1Q5c12cG8YRqqJlUE)hvxWpfBK2oiJpG3wtqY3pQfTuaLRXe8ZmPnB4iRf5fZ1igkrMaK8MzbqG66HGgDPWqTMzsB2WrwlYlMRrmuImbi5nq1fHHAnZXX6erwlQ2lUFNLk2avxbTNlvalXgmi5)fvxWp1AUw1emSgX2mz5cbnUQ)lvdqUgKOeZsh(hsryOwZaKRbjkXavxSuyOwZaKRbjkXi2XbjUtEjsbuWcagQ1ma5AqIsmy1LLrJggQ1myLjoL3QNWavJgTLQ)lvZXX6erwlQ2lUFNLk2S0H)HubTNlvalXgmi5)fvxWp1AUwjTDqgTDr3HvApxQawInyqY)lQUGFQ1CTcRUcKreawA7c(viOXv9FPAWQRazebGL2UGFMLo8peApxQawInyqY)lQUGFQ1CTAUqTJ73zP6FHGgxlv)xQMAb44FC)olv)by1S0H)HGgT6)s1ulah)J73zP6paRMLo8pKILAz9utdiwC)olv)nUubDxffTu9FPAWktCI73zP6VzPd)dbnAlRNAWktCI73zP6VXLkO7kQ(VunyLjoX97Su93S0H)Hq75sfWsSbds(Fr1f8tTMRvpG3wtqYhHzVs75sfWsSbds(Fr1f8tTMRvT3plITzYYfEyDbjpxuluwI8xuDb)umxule04kwtmSTd)J2ZLkGLydgK8)IQl4NAnxRAVFweBZKLl8W6csEUOwiOX9W6UZs1GaWQNY1FLq75sfWsSbds(Fr1f8tTMRvnbdRrSntwUWdRli55Ik52DcmGLeuQUJQ7avu7OYKBvUibjpMCR0NAMqhcnuqAWLkGL0WdWk2q7rUoKAZeK7fCGExbSSVq4nLCFawXeoixmi5)fvxWpLWbbfujCqUlD4FieojxxQawsUT3plITzYYKRua0jao5wknyjnOazzqYtdOrtdim10E)Si2MjlBe74GetdDYLg4Li0aA00G6)s14y5sepLZS0H)HqdfPbeMAAVFweBZKLnIDCqIPHoPHsPbjJ9iSQsJJLlr8uoJyhhKyAWAAagQ1mowUeXt5miqcxbSKgQGgksdsg7ryvLghlxI4PCgXooiX0qN0qbPHI0qP0GL0G6)s1GvM4e3VZs1FZsh(hcnGgnnO(VunyLjoX97Su93S0H)HqdfPbjJ9iSQsdwzItC)olv)nIDCqIPHoPbuRUdAOcAOcAOinuknad1AMQajsKhcRgS6YY0qN0aQfKgqJMgGHAnZ7D9igsWpdunnGgnnyjnad1Ag4NXqEiSAGQPHkixzjYFr1f8tXeuqLOeuQMWb5U0H)Hq4KCLcGobWjx1)LQXXYLiEkNzPd)dHgksdLsdk4mAOFU0qL0bnGgnnad1Ag4NXqEiSAGQPHkOHI0GKXEewvP59UEegsGvJyhhKyAOFAOdAOinuknyjnup1GvM4e3VZs1FJlvq3rdOrtdwsdQ)lvdwzItC)olv)nlD4Fi0qf0qrAOuAWsAq9FPAaY1GeLyw6W)qOb0OPblPbyOwZaKRbjkXavtdfPblPbjJ9iSQsdqUgKOedunnub56sfWsY1XYLiEkhrjOuzchK7sh(hcHtYvka6eaNCv)xQM97Su9pc)ownlD4Fi0qrAOuAq9FPAoowNiYAr1EX97SuXMLo8peAOinuknad1AMJJ1jISwuTxC)olvSbQMgksdhFpwfSdn0jnujDqdOrtdwsdWqTM54yDIiRfv7f3VZsfBGQPHkOb0OPblPb1)LQ54yDIiRfv7f3VZsfBw6W)qOHkOHI0qP0GL0qP0q9udwzItC)olv)nUubDhnuKgu)xQgSYeN4(DwQ(Bw6W)qOHkOHI0amuRzQcKirEiSAWQlltdDsdOwqAOcY1LkGLK7(DwQ(hHFhReLGsbjCqUlD4FieojxPaOtaCYv9FPAWktCkVvpHzPd)dHgksdLsdchGex3LQXrqWgjdkvAOtAOY0aA00GWbiX1DPACeeSbK0q)0Gf2bnubnuKgkLgo(ESkyhAOtAOGfKgQGCDPcyj5IvM4uEREcIsqXcjCqUlD4FieojxPaOtaCYv9FPAM0Mbs(i2MjlBw6W)qOHI0GKXEewvP59UEegsGvJyhhKyAOtU0qhKRlvalj3jTzGKpITzYYeLGsLq4GCx6W)qiCsUsbqNa4KR6)s1mPndK8rSntw2S0H)HqdfPbyOwZmPndK8rSntw2avtUUubSKCFVRhHHeyLOeuSieoi3Lo8pecNKRua0jao5Q(VunpWcGaiXJZF8OY0DmlD4FiKRlvalj3hybqaK4X5pEuz6oeLGsbIWb5U0H)Hq4KCLcGobWjxyOwZGvM4uEREcdunnuKgW17)O6c(PyJ02bz8b82AcsEAOtAOAAOinuknad1AMJJ1jISwuTxC)olvSbQMgQGCDPcyj5(aEBnbjFeM9krjO0heoi3Lo8pecNKRua0jao5cd1AMjTzdhzTiVyUgXqjYeGK3avtdfPHsPblPb1)LQ54yDIiRfv7f3VZsfBw6W)qOb0OPbyOwZCCSorK1IQ9I73zPInq10qfKRlvalj35c12cG8YJOeuqTdchK7sh(hcHtYvka6eaNClLgW17)O6c(PyJ02bz8b82AcsEAOFAavAOcAOinuknyjnGWut79ZIyBMSSrSMyyBh(hnGgnnup1GvM4e3VZs1FJlvq3rdvqdfPHsPblPb1)LQ54yDIiRfv7f3VZsfBw6W)qOb0OPbyOwZCCSorK1IQ9I73zPInq10aA00GKXEewvP59UEegsGvJyhhKyAOFAOdAOinC89yvWo0q)CPH(OAAOcY1LkGLK7CHABbqE5ruckOIkHdYDPd)dHWj5kfaDcGtUQ)lvZXX6erwlQ2lUFNLk2S0H)HqdfPHsPbyOwZCCSorK1IQ9I73zPInq10aA00GKXEewvP59UEegsGvJyhhKyAOFAOdAOinC89yvWo0q)CPH(OAAanAAaxV)JQl4NInsBhKXhWBRji5PHoPHQPHI0qrAagQ1myLjoL3QNWavtdfPbjJ9iSQsZ7D9imKaRgXooiX0qNCPbEjcnub56sfWsYDUqTJyBMSmrjOGA1eoi3Lo8pecNKRua0jao5wp1GvM4e3VZs1FJlvq3rdfPb1)LQbRmXjUFNLQ)MLo8peAOinuknyjnad1AM376rmKGFgOAAOinad1Ag4NXqEiSAGQPHkixxQawsUpG3wtqYhHzVsuckOwzchK7sh(hcHtYvka6eaNClLgGHAndwzIt5T6jmIDCqIPHoPbunOsdfanWlrOHcGgGHAndwzIt5T6jmy1LLPb0OPbyOwZGvM4uEREcdunnuKgGHAnZXX6erwlQ2lUFNLk2avtdvqUUubSKCFaVTMGKpcZELOeuqTGeoi3Lo8pecNKRua0jao5Q(Vuna5AqIsmlD4Fi0qrAq9FPAoowNiYAr1EX97SuXMLo8peAOinad1AgGCnirjgOAAOinad1AMJJ1jISwuTxC)olvSbQMCDPcyj52emSgX2mzzIsqbvlKWb5U0H)Hq4KCLcGobWjxyOwZ4y5sepLZavtUUubSKCFVRhHHeyLOeuqTsiCqUlD4FieojxPaOtaCYvYypcRQmkMlvAOinyjnO(VunhhRtezTOAV4(DwQyZsh(hc56sfWsY99UEegsGvIsqbvlcHdYDPd)dHWj5kfaDcGtUQ)lvdqUgKOeZsh(hcnuKgSKgkLgo(ESkyhAOFAWIyH0qrAqYypcRQ08ExpcdjWQrSJdsmn0jxAOdAOcAOinuknyjnO(VunyLjoX97Su93S0H)HqdOrtdwsd1tnyLjoX97Su934sf0D0qfKRlvaljxGCnirjeLGcQfichK7sh(hcHtYvka6eaNCLm2JWQkJI5sLgksdsBxWpmn0pnO(VuntAZISwuTxC)olvSzPd)dHCDPcyj5(ExpcdjWkrjOGAFq4GCx6W)qiCsUsbqNa4KR6)s1aKRbjkXS0H)HqdfPbyOwZaKRbjkXavtdfPbyOwZaKRbjkXi2XbjMg6Kgq1Gknua0aVeHgkaAagQ1ma5AqIsmy1LLjxxQawsUnbdRrSntwMOeuQUdchK7sh(hcHtYvka6eaNCLm2JWQkJI5sLCDPcyj5(ExpcdjWkrjOunQeoi3Lo8pecNKRlvalj327NfX2mzzYvka6eaNCfRjg22H)rUYsK)IQl4NIjOGkrjOuD1eoi3Lo8pecNKRua0jao5IR3)r1f8tXgPTdY4d4T1eK80q)0aQ0qrAWsAqaLRXe8ZmPnB4iRf5fZ1igkrMaK8MzbqG66HqdOrtdLsdWqTMzsB2WrwlYlMRrmuImbi5nq10qrAagQ1mhhRtezTOAV4(DwQydunnub56sfWsYDUqTTaiV8ikbLQRmHdYDPd)dHWj5kfaDcGtUQ)lvdqUgKOeZsh(hcnuKgGHAndqUgKOedunnuKgkLgGHAndqUgKOeJyhhKyAOtAGxIqdfanuqAOaObyOwZaKRbjkXGvxwMgqJMgGHAndwzIt5T6jmq10aA00GL0G6)s1CCSorK1IQ9I73zPInlD4Fi0qfKRlvalj3MGH1i2MjltuckvxqchKRlvaljxPTdYOTl6oSsUlD4FieojkbLQTqchK7sh(hcHtYvka6eaNCv)xQgS6kqgrayPTl4NzPd)dHCDPcyj5IvxbYicalTDb)ikbLQRechK7sh(hcHtYvka6eaNCTKgu)xQMAb44FC)olv)by1S0H)HqdOrtdQ)lvtTaC8pUFNLQ)aSAw6W)qOHI0qP0GL0q9utdiwC)olv)nUubDhnubnuKgSKgu)xQgSYeN4(DwQ(Bw6W)qOb0OPblPH6PgSYeN4(DwQ(BCPc6oAOinO(VunyLjoX97Su93S0H)HqUUubSKCNlu74(DwQ(tuckvBriCqUUubSKCFaVTMGKpcZELCx6W)qiCsuckvxGiCqUhwxqYtqbvYDPd)lEyDbjpHtY1LkGLKB79ZIyBMSm5klr(lQUGFkMGcQKRua0jao5kwtmSTd)JCx6W)qiCsuckv3heoi3Lo8pecNK7sh(x8W6csEcNKRua0jao5EyD3zPAqay1t5OH(PHkHCDPcyj52E)Si2MjltUhwxqYtqbvIsqPYDq4GCpSUGKNGcQK7sh(x8W6csEcNKRlvalj3MGH1i2MjltUlD4FieojkrjxNncheuqLWb56sfWsYvA7GmA7IUdRK7sh(hcHtIsqPAchK7sh(hcHtYvka6eaNCv)xQgSYeNYB1tyw6W)qixxQawsUyLjoL3QNGOeuQmHdYDPd)dHWj56sfWsYT9(zrSntwMCLcGobWjxXAIHTD4F0qrAOuAaxV)JQl4NInsBhKXhWBRji5PHoPblKgqJMgSKgQNAWktCI73zP6VXLkO7Ob0OPbC9(pQUGFk2iTDqgFaVTMGKNg4sdvMgksdWqTMPkqIe5HWQbRUSmn0jnGAbPHkixzjYFr1f8tXeuqLOeukiHdYDPd)dHWj5kfaDcGtUQ)lvZK2mqYhX2mzzZsh(hc56sfWsYDsBgi5JyBMSmrjOyHeoi3Lo8pecNKRua0jao5cd1AgSYeNYB1tyGQPHI0amuRzM0Mbs(i2MjlBGQjxxQawsUsBhKXhWBRji5jkbLkHWb5U0H)Hq4KCLcGobWjxyOwZmPndK8rSntw2avtdfPbjJ9iSQsdwzIt5T6jmIDCqIPH(PbyOwZmPndK8rSntw2i2XbjMgSMgQMgkaAGxIqUUubSKCNluBlaYlpIsqXIq4GCx6W)qiCsUsbqNa4KR6)s14y5sepLZS0H)HqdfPHsPblPH6PgSYeN4(DwQ(BCPc6oAOcAOinuknyjnO(Vuna5AqIsmlD4Fi0aA00GL0amuRzaY1GeLyGQPHI0GL0GKXEewvPbixdsuIbQMgQGCDPcyj56y5sepLJOeukqeoi3Lo8pecNKRua0jao5Q(VunpWcGaiXJZF8OY0DmlD4FiKRlvalj3hybqaK4X5pEuz6oeLGsFq4GCx6W)qiCsUsbqNa4KR6)s1CCSorK1IQ9I73zPInlD4Fi0qrA447XQGDOH(5sdwyh0qrAagQ1mV31Jyib)mq1KRlvalj3376ryibwjkbfu7GWb5U0H)Hq4KCLcGobWjx1)LQzsBgi5JyBMSSzPd)dHCDPcyj5oPndK8rSntwMOeuqfvchKRlvalj35c12cG8YJCx6W)qiCsuckOwnHdYDPd)dHWj5kfaDcGtUcOCnMGFMjTzdhzTiVyUgXqjYeGK3mlacuxpeAOinyjnad1AMjTzdhzTiVyUgXqjYeGK3avtdfPHsPb1)LQ54yDIiRfv7f3VZsfBw6W)qOb0OPbyOwZCCSorK1IQ9I73zPInq10aA00aUE)hvxWpfBK2oiJpG3wtqYtd9tdvMgQGCDPcyj5oxO2rSntwMOeuqTYeoi3Lo8pecNKRua0jao5AjnO(VunhhRtezTOAV4(DwQyZsh(hcnGgnnad1AgSYeNYB1tyGQPb0OPHJVhRc2Hg6NlnuknGAhDqdfyAOG0qbqd469FuDb)uSrA7Gm(aEBnbjpnubnGgnnad1AMJJ1jISwuTxC)olvSbQMgqJMgW17)O6c(PyJ02bz8b82AcsEAOFAOYKRlvalj35c12cG8YJOeuqTGeoi3Lo8pecNKRua0jao5cd1AgSYeNYB1tye74GetdDsdvMgkaAGxIqdfanad1AgSYeNYB1tyWQlltUUubSKCL2oiJpG3wtqYtuckOAHeoi3Lo8pecNKRua0jao5cd1AM376rmKGFgOAAOinGR3)r1f8tXgPTdY4d4T1eK80qN0qbPHI0qP0GL0q9udwzItC)olv)nUubDhnubnuKgqyQP9(zrSntw2OazzqYtUUubSKCFVRhHHeyLOeuqTsiCqUlD4FieojxPaOtaCYfxV)JQl4NInsBhKXhWBRji5PHoPHcsdfPblPbyOwZ4y5sepLZavtUUubSKCbY1GeLquckOAriCqUlD4FieojxPaOtaCYfxV)JQl4NInsBhKXhWBRji5PHoPHcsdfPbyOwZaKRbjkXavtdfPblPbyOwZ4y5sepLZavtUUubSKCBcgwJyBMSmrjOGAbIWb5U0H)Hq4KCLcGobWjx1)LQz)olv)JWVJvZsh(hcnuKgW17)O6c(PyJ02bz8b82AcsEAOtAOG0qrAOuAWsAOEQbRmXjUFNLQ)gxQGUJgQGCDPcyj5UFNLQ)r43XkrjOGAFq4GCDPcyj5kTDqgFaVTMGKNCx6W)qiCsuckv3bHdYDPd)dHWj5U0H)fpSUGKNWj5kfaDcGtUWqTM59UEedj4NbQMgksdsg7ryvLrXCPsUUubSKCFVRhHHeyLCpSUGKNGcQeLGs1Os4GCpSUGKNGcQK7sh(x8W6csEcNKRlvalj327NfX2mzzYvwI8xuDb)umbfujxPaOtaCYvSMyyBh(h5U0H)Hq4KOeuQUAchK7H1fK8euqLCx6W)IhwxqYt4KCDPcyj52emSgX2mzzYDPd)dHWjrjk5ISMd9kHdckOs4GCx6W)qiWKRua0jao5699eaDgpLdRc)JIHzPNYzw6W)qixxQawsUWpJH8qyLOeuQMWb5U0H)Hq4KCLcGobWj3gG3wJIDCqIPHoPHkPdAanAAqYypcRQ0Wd5ceGNrwl699em12i2XbjMg6KgQChKRlvalj3AMcyjrjOuzchKRlvalj3QajseBpxqUlD4FieojkbLcs4GCDPcyj5cHxeO7Gj3Lo8pecNeLGIfs4GCDPcyj52aIf3VZs1FYDPd)dHWjrjOujeoixxQawsUyLjoX97Su9NCx6W)qiCsuckwechKRlvaljxjlLlvHRdj2E)mYDPd)dHWjrjOuGiCqUUubSKCHFgdjYAr1EXL7uc5U0H)Hq4KOeu6dchKRlvaljxEixGa8mYArVVNGP2K7sh(hcHtIsqb1oiCqUUubSKCBmjeEirVVNaOlcp)qUlD4FieojkbfurLWb56sfWsYTgsaALas(i87yLCx6W)qiCsuckOwnHdY1LkGLKRAViucZGsKyJjKJCx6W)qiCsuckOwzchKRlvalj3Zomrjrwl(qsaserm)Gj3Lo8pecNeLGcQfKWb56sfWsYvaQR)fbzex7YrUlD4FieojkbfuTqchKRlvalj3QyIhP7azumml9uoYDPd)dHWjrjOGALq4GCx6W)qiCsUsbqNa4KR6c(Pg75VAhRLkn0pnuG6GgqJMguxWp1yp)v7yTuPHoPHQ7GgqJMgAaEBnk2XbjMg6KgQChKRlvaljxX8AqYhBVFgMOeuq1Iq4GCDPcyj5ApxOXHXlLJCx6W)qiCsuckOwGiCqUlD4FieojxPaOtaCY1sAq9FPACSCjINYzw6W)qOb0OPbyOwZ4y5sepLZavtdOrtdsg7ryvLghlxI4PCgXooiX0q)0Gf2b56sfWsYf(zmKydsucrjOGAFq4GCx6W)qiCsUsbqNa4KRL0G6)s14y5sepLZS0H)HqdOrtdWqTMXXYLiEkNbQMCDPcyj5cpbEIYGKNOeuQUdchK7sh(hcHtYvka6eaNCTKgu)xQghlxI4PCMLo8peAanAAagQ1mowUeXt5mq10aA00GKXEewvPXXYLiEkNrSJdsmn0pnyHDqUUubSKCBaXGFgdHOeuQgvchK7sh(hcHtYvka6eaNCTKgu)xQghlxI4PCMLo8peAanAAagQ1mowUeXt5mq10aA00GKXEewvPXXYLiEkNrSJdsmn0pnyHDqUUubSKC9uoSk8pk9)jkbLQRMWb5U0H)Hq4KCLcGobWjxlPb1)LQXXYLiEkNzPd)dHgqJMgSKgGHAnJJLlr8uodun56sfWsYf25JSwufazzmrjOuDLjCqUlD4FieojxxQawsU1cWHjqa(hRY7oYvka6eaNCTKgGHAntTaCyceG)XQ8UZavtUYsK)IQl4NIjOGkrjOuDbjCqUUubSKC7oC9erLP7qUlD4FieojkbLQTqchKRlvalj3MVOk8e3GWawsUlD4FieojkbLQRechK7sh(hcHtYvka6eaNClLgo(ESkyhAOFU0qL0bnGgnnizShHvvAEVRhHHey1i2XbjMg6KlnWlrOb0OPbyOwZ8ExpIHe8ZavtdvqUUubSKCN0Mbs(i2MjltuckvBriCqUlD4FieojxPaOtaCY1LkO7Il3bmmn0pnunnuKgkLgW17)O6c(PyJ02bz8b82AcsEAOFAOAAanAAaxV)JQl4NInV31JWZp0q)0q10qfKRlvaljxbugDPcyz8byLCFawJPFg56SruckvxGiCqUlD4FieojxxQawsUcOm6sfWY4dWk5(aSgt)mYfds(Fr1f8tjkrj3AXKSdSReoiOGkHdYDPd)dHWj5M(zKR33yBx44yJLAK1I1SQMGCDPcyj569n22foo2yPgzTynRQjikbLQjCqUUubSKCRzkGLK7sh(hcHtIsuIsuIsi]] )

end
