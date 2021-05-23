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
            id = 77762,
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
            cast = function ()
                if buff.chains_of_devastation_ch.up then return 0 end
                return 2.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 136042,

            handler = function ()
                removeBuff( "chains_of_devastation_ch" )
                removeBuff( "echoing_shock" )

                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_cl" )
                end
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.stormkeeper.up or buff.chains_of_devastation_cl.up ) and 0 or ( 2 * haste ) end,
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
                removeBuff( "chains_of_devastation_cl" )

                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_ch" )
                end

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

            usable = function ()
                return max( cooldown.fire_elemental.true_remains, cooldown.storm_elemental.true_remains ) > 0, "DPS elementals must be on CD first"
            end,

            timeToReady = function ()
                return max( pet.fire_elemental.remains, pet.storm_elemental.remains, pet.primal_fire_elemental.remains, pet.primal_storm_elemental.remains )
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
                    duration = 25,
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

            copy = 305485
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

            usable = function () return storm_elemental.up end,
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

        potion = "potion_of_spectral_intellect",

        package = "Elemental",
    } )

    --[[ spec:RegisterSetting( "micromanage_pets", true, {
        name = "Micromanage Primal Elemental Pets",
        desc = "If checked, Meteor, Eye of the Storm, etc. will appear in your recommendations.",
        type = "toggle",
        width = 1.5
    } ) ]]

    spec:RegisterPack( "Elemental", 20210419, [[dquOFbqiQcpciOnjr(KeLQgLuKtjr1QqPsVIQIzHs5wsuk2fv(fvrddsvhdszzsr9muQyAaHUgKk2gkv13qPkghkvPZjrjRdsLQMhqY9GK9bK6GqQeTquIhkrPKjkrPIlce4KqQuwjq1mLOuPBcPsANaLFcPs4Ps1urjDvivQSxO(RGbl0HPSyiEmPMmIUSYML0NrXOLWPv51uvnBvDBa7w0Vr1WLshxIILJ0ZbnDIRJW2LcFhiA8suk15PQ08PkTFsgJgMvCN0KHbRz03mAOherRSCOvwObISd7f3fFBhU3AA)gZW90agUdc(bSuSh3BnFFUrIzf3HCcQE4EHiTq09E6jZjfeionhWt4bq8MC8utTQ4j8a0EI7ie3lOBjgb3jnzyWAg9nJg6br0klhALfAGi7Go4oSDAmynZ(nJ7fhj5smcUtoOg3bb)awk2RI9cdWsf4OlBP3RIO1mBQyZOVz0uGRaVSvHLmdIUxbEzJkIULAoTLtnzQiCICjd0bft7pGquRJQIvovfr30Rsq9LnvSlCkG)T2rDkWlBur0LKKQi66KXPQOLKQiiW3PI8Qkkftf7cNcOIgJDPd3BP869d3bHGqvee8dyPyVk2lmalvGdcbHQi6Yw69QiAnZMk2m6Bgnf4kWbHGqvSSvHLmdIUxboieeQILnQi6wQ50wo1KPIWjYLmqhumT)acrToQkw5uveDtVkb1x2uXUWPa(3Ah1PaheccvXYgveDjjPkIUozCQkAjPkcc8DQiVQIsXuXUWPaQOXyx6uGRaheQIGGY2ttiJufxJr9vfLdyQOumv00cNQIhufTg29gYpNcCtlhpHUw60CaetqnJkfH9dyPypBxfLhI9lfxl9aSpSFalf7pO4wAi)ivGdcvr0DWPIDHtb8V1oQk2sNMdGyIksK)GqveYbMkAKKqveK3)QiS1azQIqopDkWnTC8e6APtZbqmXhuEcfofW)w7OSDvuI9lfhu4ua)BTJ6wAi)il1e1oYWASuCgjj0P5ePak2XRxQDKH1yP4mssO7sqJoOVCf4MwoEcDT0P5aiM4dkp3pGLI9bK3GcBxfLy)sXTFalf7diVbf3sd5hPcCtlhpHUw60Caet8bLNV1WcieuOW2F5cAsuOdBxfLhI9lf3(bSuSpG8guClnKFKkWnTC8e6APtZbqmXhuEwFdybybx7NTRIIUkDWcd5NcCtlhpHUw60Caet8bLNTC54PcCf4GqveDlLrPeTIkYRQO2Gc0Pa30YXtOpO8eKxsgGfZOkWnTC8e6dkpHTh9eqAV)rHbgQPhBa8gxYGcnf4MwoEc9bLNTC54PcCtlhpH(GYtc4cNmaOcCtlhpH(GYZ6rxy)awk2Ra30YXtOpO8eyY4uf4MwoEc9bLNqHtbc7hWsXEf4MwoEc9bLNZ3f41GuSau4ua2UkkeIA1PT)d)Xui5Lmo6aSlHGgfAOxbUPLJNqFq5jYZ5KHkb1x2Ukkpe7xkodQxsAPEULgYpsVEriQvNb1ljTuphrRxVAo)j5GmDguVK0s9C0byxcbn6GEf4MwoEc9bLNiJch1)LmSDvuEi2VuCguVK0s9ClnKFKE9IquRodQxsAPEoIwf4MwoEc9bLN1JoKNZjz7QO8qSFP4mOEjPL65wAi)i96fHOwDguVK0s9CeTE9Q58NKdY0zq9ssl1ZrhGDje0Od6vGBA54j0huEAPEqHAFqB)Z2vr5Hy)sXzq9ssl1ZT0q(r61lcrT6mOEjPL65iA96vZ5pjhKPZG6LKwQNJoa7siOrh0Ra30YXtOpO8eXyc8AqON2pKTRIYdX(LIZG6LKwQNBPH8J0RxpqiQvNb1ljTuphrRcCf4MwoEc9bLNT0dGtjp7dG0Am20(Q)feJYmbIcn2UkkpqiQvxl9a4uYZ(aiTgZr0Qa30YXtOpO8SXGTJgeUmaf4MwoEc9bLNvBbHAjSsapEY2vr5Hy)sXbyqz0aVgKIf2pGLc0T0q(r61lcrT6amOmAGxdsXc7hWsb6iAvGRa30YXtOpO8KsKbtlhpd)bf2sdyOm(y7QOmTCnwy5aUbbDZLAc2U)dIrzMaD6c7YWFmfsEjdOB2Rxy7(pigLzc09wdlGmda0nxUcCtlhpH(GYtkrgmTC8m8huylnGHcEjZVGyuMjSbf6PfuOX2vr5Hy)sXbfofiSFalf7DlnKFKLmTCnwy5aUbbfQMvGBA54j0huEsjYGPLJNH)GcBPbmuWfGxY8ligLzcBqHEAbfASDvuI9lfhu4uGW(bSuS3T0q(rwY0Y1yHLd4geuOAwbUcCtlhpHoJpuZOsrzim)JTRIcHOwDtxWVKjal4A)oIwf4MwoEcDgF(GYtDHDzOWOnguuGBA54j0z85dkpHcNc4FRDu2UkkX(LIdkCkG)T2rDlnKFKkWnTC8e6m(8bLN13awawW1(zt7R(xqmkZeik0y7QOORshSWq(vQjtlxJfi5IR(gWcWcU2pOyNsMwUglSCa3GGcf641lLixLtzMd63xe6m)Jcd1BuFdKd4GZTYqCTTJSCf4MwoEcDgF(GYZ6Balal4A)SDvuEyA5ASajxC13awawW1(vGBA54j0z85dkpNUGFjtawW1(z7QOe7xkUPl4xYeGfCTF3sd5hzjaBpuOCaqJI9rVcCtlhpHoJpFq5Pb1ljTup2UkkX(LIZG6LKwQNBPH8JSutE0oXbfofiSFalf7DMwUgR8sn5Hy)sXD6vjO(6wAi)i961deIA1D6vjO(6iAl5HMZFsoit3PxLG6RJOTCf4MwoEcDgF(GYZ)kdXrgamgaliCzaSDvuI9lf3FLH4idagdGfeUma3sd5hPcCtlhpHoJpFq55mQueGfCTF2UkkkrUkNYm30f8bd8AGHotcqIKC0lzCRmexB7il5bcrT6MUGpyGxdm0zsasKKJEjJJOvbUPLJNqNXNpO8Cgvkc7hWsXE2UkkkrUkNYmh5wRqhaNgGcpNBLH4ABhzPM8qSFP4APhG9H9dyPy)bf3sd5hPxVn5r7ehu4uGW(bSuS3zA5ASsE0oXvp6c7hWsXENPLRXkVCf4MwoEcDgF(GYZ3Aybeckuyt7R(xqmkZeik0y7QOGT7)GyuMjqNUWUm8htHKxYakq0RxeIA19wdlajOmZr061BtI9lfhGbLrd8Aqkwy)awkq3sd5hzjpqiQvhGbLrd8Aqkwy)awkqhrBjaBpuOCaqJI9rF5kWbHQiRuFvrHRImgWurqGrLIYqy(NkcYtkur0vdkJQI8Qkkftfbb)awkqveHOwvrqwSufRhtHCjJkYoQOyuMjqNkw2HNL9IkYBmQ2Avr0vBpuOCapuGBA54j0z85dkpNrLIYqy(hBxfLhI9lfhGbLrd8Aqkwy)awkq3sd5hPxVie1QdkCkG)T2rDeTE9cy7HcLdaAunHg6rFzdiYUW29FqmkZeOtxyxg(JPqYlzk3RxeIA1byqz0aVgKIf2pGLc0r061lSD)heJYmb60f2LH)ykK8sgqZokWbHQi6Q5FQiKGov0xoHksYZYErfFoCQOPIDHtb8V1oQkIquRof4MwoEcDgF(GYtDHDz4pMcjVKHTRIcHOwDqHtb8V1oQJoa7siOyh2LrtYUie1QdkCkG)T2rDqX0(vGdcvr0f57RkQnOOILDTgMkYcbfkQipvrPGUPIIrzMavXRQINOIhufTufVekwkQOLKQyx4uavee8dyPyVkEqvem0fSQIMwUgZPa30YXtOZ4ZhuE(wdlGqqHcBxffcrT6ERHfGeuM5iAlbB3)bXOmtGoDHDz4pMcjVKbuGyPM8ODIdkCkqy)awk27mTCnw5Li5IR(gWcWcU2VtoT)lzuGdcvr0DWPIGGFalf7vrwEdkQOXyxcfvKOvffUkYoQOyuMjqv0GQ4Ztgv0GQyx4uavee8dyPyVkEqvm5IkAA5AmNcCtlhpHoJpFq55(bSuSpG8guy7QOe7xkU9dyPyFa5nO4wAi)ilbB3)bXOmtGoDHDz4pMcjVKbuOtPM8ODIdkCkqy)awk27mTCnw5kWnTC8e6m(8bLNV1WciZay7QOe7xkodQxsAPEULgYpsf4MwoEcDgF(GYtDHDz4pMcjVKrbUPLJNqNXNpO88TgwaHGcf2a4nUKbfASDvuie1Q7TgwasqzMJOTKMZFsoiZaDMwuGBA54j0z85dkpRVbSaSGR9ZgaVXLmOqJnTV6FbXOmtGOqJTRIIUkDWcd5NcCtlhpHoJpFq5zLYHsawW1(zdG34sguOPaxbUPLJNqhCb4Lm)cIrzMGQ(gWcWcU2pBAF1)cIrzMarHgBxfvt0byxcbfkgnz5LAcHOwDV1WcqckZCeTE96bcrT6qEoN8jGIJOTCf4MwoEcDWfGxY8ligLzIpO8C)awk2hqEdkSDvuI9lf3(bSuSpG8guClnKFKkWnTC8e6GlaVK5xqmkZeFq5ju4ua)BTJY2vrj2VuCqHtb8V1oQBPH8JSuta2EOq5aGcebXYvGBA54j0bxaEjZVGyuMj(GYZPl4xYeGfCTF2UkkX(LIB6c(Lmbybx73T0q(rQa30YXtOdUa8sMFbXOmt8bLNV1WcieuOW2vrHquRoqEjzGHakoOyA)Gcn2RxVie1Q7TgwasqzMJOvbUPLJNqhCb4Lm)cIrzM4dkp)JPqYlzci8xy7QOqiQvhu4ua)BTJ6iAvGBA54j0bxaEjZVGyuMj(GYZzuPOmeM)X2vrHquRUPl4dg41adDMeGej5OxY4iAvGBA54j0bxaEjZVGyuMj(GYZzuPOmeM)X2vr1eSD)heJYmb60f2LH)ykK8sgqJw5LAYdsU4QVbSaSGR97ORshSWq(vUcCtlhpHo4cWlz(feJYmXhuEoJkfbybx7NTRIc2U)dIrzMaD6c7YWFmfsEjdOAUeGThkuoaOrX(OVutie1QdKxsgyiGIdkM2pOAg9E9cy7HcLda6Yc9L71BtuICvoLzUPl4dg41adDMeGej5OxY4wziU22rwYdeIA1nDbFWaVgyOZKaKijh9sghrB5kWnTC8e6GlaVK5xqmkZeFq55FmfsEjtaH)cBxfvtie1QdkCkG)T2rD0byxcbfCICjd0bft7pGquRJYUmAs2fHOwDqHtb8V1oQdkM2VxVie1QdkCkG)T2rDeTLqiQvhGbLrd8Aqkwy)awkqhrB5kWnTC8e6GlaVK5xqmkZeFq5zLYHsawW1(z7QOe7xkUtVkb1x3sd5hzjX(LIdWGYObEniflSFalfOBPH8JSecrT6o9QeuFDeTLqiQvhGbLrd8Aqkwy)awkqhrRcCtlhpHo4cWlz(feJYmXhuE(wdlGqqHcBxffcrT6mOEjPL65iAvGBA54j0bxaEjZVGyuMj(GYZ3Aybeckuy7QO0C(tYbzgOZ0sjpe7xkoadkJg41GuSW(bSuGULgYpsf4MwoEcDWfGxY8ligLzIpO880Rsq9LTRIsSFP4o9QeuFDlnKFKL8OjaBpuOCaqZEqNsAo)j5GmDV1WcieuO4OdWUeckuOVCf4MwoEcDWfGxY8ligLzIpO88TgwaHGcf2UkknN)KCqMb6mTusxyuMbbTy)sXnDbpWRbPyH9dyPaDlnKFKkWnTC8e6GlaVK5xqmkZeFq5zLYHsawW1(z7QOe7xkUtVkb1x3sd5hzjeIA1D6vjO(6iAvGBA54j0bxaEjZVGyuMj(GYtDHDzOWOnguuGBA54j0bxaEjZVGyuMj(GYtOyYPdKhuxyuMX2vrj2VuCqXKthipOUWOmZT0q(rQa30YXtOdUa8sMFbXOmt8bLNZOsry)awk2Z2vr5Hy)sX1spa7d7hWsX(dkULgYpsVEf7xkUw6byFy)awk2FqXT0q(rwQjpAN4GcNce2pGLI9otlxJvUcCtlhpHo4cWlz(feJYmXhuEQlSld)Xui5LmSDvuW29FqmkZeOtxyxg(JPqYlzq1ScCtlhpHo4cWlz(feJYmXhuE(htHKxYeq4VOa30YXtOdUa8sMFbXOmt8bLN13awawW1(zdG34sguOXM2x9VGyuMjquOX2vrrxLoyHH8tbUPLJNqhCb4Lm)cIrzM4dkpRVbSaSGR9ZgaVXLmOqJTRIcG3yalfh5bfl1d0SVcCtlhpHo4cWlz(feJYmXhuEwPCOeGfCTF2a4nUKbfAkWvGBA54j0bVK5xqmkZeu13awawW1(zt7R(xqmkZeik0y7QOAYd50(VKXRxsU4QVbSaSGR97OdWUeckumAsVEf7xkodQxsAPEULgYpYsKCXvFdybybx73rhGDjeunP58NKdY0zq9ssl1ZrhGDj0heIA1zq9ssl1Zrsqn54z5L0C(tYbz6mOEjPL65OdWUeckqS8snHquRU3AybibLzoIwVE9aHOwDipNt(eqXr0wUcCtlhpHo4Lm)cIrzM4dkpnOEjPL6X2vrj2VuCguVK0s9ClnKFKLAsoGbAuSp696fHOwDipNt(eqXr0wEPM0C(tYbz6ERHfqiOqXrhGDje0OV8sn5Hy)sXD6vjO(6wAi)i961deIA1D6vjO(6iAl5HMZFsoit3PxLG6RJOTCf4MwoEcDWlz(feJYmXhuEUFalf7diVbf2UkkX(LIB)awk2hqEdkULgYpYsnj2VuCagugnWRbPyH9dyPaDlnKFKLAcHOwDagugnWRbPyH9dyPaDeTLaS9qHYbaf7JEVE9aHOwDagugnWRbPyH9dyPaDeTL71RhI9lfhGbLrd8Aqkwy)awkq3sd5hz5kWnTC8e6GxY8ligLzIpO8ekCkG)T2rz7QOe7xkoOWPa(3Ah1T0q(rwQjQDKH1yP4mssOtZjsbuSJxVu7idRXsXzKKq3LGgDqF5LAcW2dfkhauGiiwUcCtlhpHo4Lm)cIrzM4dkpNUGFjtawW1(z7QOe7xkUPl4xYeGfCTF3sd5hzjnN)KCqMU3AybeckuC0byxcbfk0Ra30YXtOdEjZVGyuMj(GYZ3Aybeckuy7QOe7xkUPl4xYeGfCTF3sd5hzjeIA1nDb)sMaSGR97iAvGBA54j0bVK5xqmkZeFq55FLH4idagdGfeUma2UkkX(LI7VYqCKbaJbWccxgGBPH8JubUPLJNqh8sMFbXOmt8bLN)Xui5Lmbe(lSDvuie1QdkCkG)T2rDeTLGT7)GyuMjqNUWUm8htHKxYaQMl1ecrT6amOmAGxdsXc7hWsb6iAlxbUPLJNqh8sMFbXOmt8bLNZOsrzim)JTRIcHOwDtxWhmWRbg6mjajsYrVKXr0wQjX(LIdWGYObEniflSFalfOBPH8JSutie1QdWGYObEniflSFalfOJO1RxnN)KCqMU3AybeckuC0byxcbn6lby7HcLdaAuLvZE9cB3)bXOmtGoDHDz4pMcjVKbunxcHOwDqHtb8V1oQJOTKMZFsoit3BnSacbfko6aSlHGcfJMSCVE9qSFP4amOmAGxdsXc7hWsb6wAi)i96vZ5pjhKPB)awk2hqEdko6aSlHGcfAo0yxgnj72C5kWnTC8e6GxY8ligLzIpO8CgvkkdH5FSDvuW29FqmkZeOtxyxg(JPqYlzanAL8GKlU6Balal4A)o6Q0blmKFL8GsKRYPmZnDbFWaVgyOZKaKijh9sg3kdX12oYsn5Hy)sXbyqz0aVgKIf2pGLc0T0q(r61lcrT6amOmAGxdsXc7hWsb6iA96vZ5pjhKP7TgwaHGcfhDa2LqqJ(sa2EOq5aGgvz1C5kWnTC8e6GxY8ligLzIpO8CgvkcWcU2pBxfLy)sXbyqz0aVgKIf2pGLc0T0q(rwQjeIA1byqz0aVgKIf2pGLc0r061RMZFsoit3BnSacbfko6aSlHGg9LaS9qHYbanQYQzVEHT7)GyuMjqNUWUm8htHKxYaQMlHquRoOWPa(3Ah1r0wsZ5pjhKP7TgwaHGcfhDa2LqqHIrtwUxVEi2VuCagugnWRbPyH9dyPaDlnKFKkWnTC8e6GxY8ligLzIpO88pMcjVKjGWFHTRIQjeIA1bfofW)w7Oo6aSlHGcorUKb6GIP9hqiQ1rzxgnj7IquRoOWPa(3Ah1bft73RxeIA1bfofW)w7OoI2sie1QdWGYObEniflSFalfOJOTCf4MwoEcDWlz(feJYmXhuEwPCOeGfCTF2UkkX(LI70Rsq91T0q(rwsSFP4amOmAGxdsXc7hWsb6wAi)ilHquRUtVkb1xhrBjeIA1byqz0aVgKIf2pGLc0r0Qa30YXtOdEjZVGyuMj(GYZ3Aybeckuy7QOqiQvNb1ljTuphrRcCtlhpHo4Lm)cIrzM4dkpFRHfqiOqHTRIsZ5pjhKzGotlL8qSFP4amOmAGxdsXc7hWsb6wAi)ivGBA54j0bVK5xqmkZeFq55PxLG6lBxfLy)sXD6vjO(6wAi)il5rta2EOq5aGM9GoL0C(tYbz6ERHfqiOqXrhGDjeuOqF5kWnTC8e6GxY8ligLzIpO88TgwaHGcf2UkknN)KCqMb6mTusxyuMbbTy)sXnDbpWRbPyH9dyPaDlnKFKkWnTC8e6GxY8ligLzIpO8Ss5qjal4A)SDvuI9lf3PxLG6RBPH8JSecrT6o9QeuFDeTLqiQv3PxLG6RJoa7siOGtKlzGoOyA)beIADu2LrtYUie1Q70Rsq91bft7xbUPLJNqh8sMFbXOmt8bLNV1WcieuOW2vrP58NKdYmqNPff4MwoEcDWlz(feJYmXhuEwFdybybx7NnTV6FbXOmtGOqJTRIIUkDWcd5NcCtlhpHo4Lm)cIrzM4dkpNrLIYqy(hBxffSD)heJYmb60f2LH)ykK8sgqJwjpOe5QCkZCtxWhmWRbg6mjajsYrVKXTYqCTTJ0RxeIA1nDbFWaVgyOZKaKijh9sghrRcCtlhpHo4Lm)cIrzM4dkpRuoucWcU2pBxfLy)sXD6vjO(6wAi)ilHquRUtVkb1xhrBPMqiQv3PxLG6RJoa7siOy0KSliYUie1Q70Rsq91bft73RxeIA1bfofW)w7OoIwVE9qSFP4amOmAGxdsXc7hWsb6wAi)ilxbUPLJNqh8sMFbXOmt8bLNvkhkbybx7NTRIIsKRYPmZTFalf7dRme3Fi0JaWTYqCTTJSKhie1QB)awk2hwziU)qOhbqGCie1QJOTKhI9lf3(bSuSpG8guClnKFKL8qSFP4MUGFjtawW1(DlnKFKkWnTC8e6GxY8ligLzIpO8uxyxgkmAJbff4MwoEcDWlz(feJYmXhuEcftoDG8G6cJYm2UkkX(LIdkMC6a5b1fgLzULgYpsf4MwoEcDWlz(feJYmXhuEoJkfH9dyPypBxfLhI9lfxl9aSpSFalf7pO4wAi)i961J2jU6rxy)awk27mTCnMcCtlhpHo4Lm)cIrzM4dkp1f2LH)ykK8sg2Ukky7(pigLzc0PlSld)Xui5LmOAwbUPLJNqh8sMFbXOmt8bLN)Xui5Lmbe(lkWnTC8e6GxY8ligLzIpO8S(gWcWcU2pBa8gxYGcn20(Q)feJYmbIcn2Ukk6Q0blmKFkWnTC8e6GxY8ligLzIpO8S(gWcWcU2pBa8gxYGcn2UkkaEJbSuCKhuSupqZ(kWnTC8e6GxY8ligLzIpO8Ss5qjal4A)SbWBCjdk0W9gJcpEIbRz03mAOherJDWDqA08sgiUJUb0YPYivr0rfnTC8uf)dkqNcCC)pOaXSI7Wlz(feJYmbZkgm0WSI7lnKFKywWDtlhpX96Balal4A)4UMEYONH7nPIEOIYP9FjJk61RksYfx9nGfGfCTFhDa2LqveuOurgnPk61Rkk2VuCguVK0s9ClnKFKQyjvKKlU6Balal4A)o6aSlHQiOuXMurnN)KCqModQxsAPEo6aSlHQOpQicrT6mOEjPL65ijOMC8uflxflPIAo)j5GmDguVK0s9C0byxcvrqPIGOkwUkwsfBsfriQv3BnSaKGYmhrRk61Rk6HkIquRoKNZjFcO4iAvXYXDTV6FbXOmtGyWqdlyWAgZkUV0q(rIzb310tg9mCxSFP4mOEjPL65wAi)ivXsQytQOCatfbnkvK9rVk61RkIquRoKNZjFcO4iAvXYvXsQytQOMZFsoit3BnSacbfko6aSlHQiOvr0RILRILuXMurpurX(LI70Rsq91T0q(rQIE9QIEOIie1Q70Rsq91r0QILurpurnN)KCqMUtVkb1xhrRkwoUBA54jUBq9ssl1dlyWyhmR4(sd5hjMfCxtpz0ZWDX(LIB)awk2hqEdkULgYpsvSKk2Kkk2VuCagugnWRbPyH9dyPaDlnKFKQyjvSjveHOwDagugnWRbPyH9dyPaDeTQyjveW2dfkhqfbLkY(Oxf96vf9qfriQvhGbLrd8Aqkwy)awkqhrRkwUk61Rk6Hkk2VuCagugnWRbPyH9dyPaDlnKFKQy54UPLJN4((bSuSpG8guWcgmqeZkUV0q(rIzb310tg9mCxSFP4GcNc4FRDu3sd5hPkwsfBsfP2rgwJLIZijHonNifveuQi7OIE9QIu7idRXsXzKKq3LQiOvr0b9Qy5QyjvSjveW2dfkhqfbLkcIGOkwoUBA54jUdfofW)w7Oybdg6Gzf3xAi)iXSG7A6jJEgUl2VuCtxWVKjal4A)ULgYpsvSKkQ58NKdY09wdlGqqHIJoa7sOkckuQi6XDtlhpX9Pl4xYeGfCTFSGbJ9XSI7lnKFKywWDn9Krpd3f7xkUPl4xYeGfCTF3sd5hPkwsfriQv30f8lzcWcU2VJOf3nTC8e3FRHfqiOqblyWypywX9LgYpsml4UMEYONH7I9lf3FLH4idagdGfeUma3sd5hjUBA54jU)xzioYaGXaybHldalyWyVywX9LgYpsml4UMEYONH7ie1QdkCkG)T2rDeTQyjve2U)dIrzMaD6c7YWFmfsEjJkckvSzvSKk2KkIquRoadkJg41GuSW(bSuGoIwvSCC30YXtC)pMcjVKjGWFblyWklmR4(sd5hjMfCxtpz0ZWDeIA1nDbFWaVgyOZKaKijh9sghrRkwsfBsff7xkoadkJg41GuSW(bSuGULgYpsvSKk2KkIquRoadkJg41GuSW(bSuGoIwv0RxvuZ5pjhKP7TgwaHGcfhDa2Lqve0Qi6vXsQiGThkuoGkcAuQyz1Sk61RkcB3)bXOmtGoDHDz4pMcjVKrfbLk2SkwsfriQvhu4ua)BTJ6iAvXsQOMZFsoit3BnSacbfko6aSlHQiOqPImAsvSCv0Rxv0dvuSFP4amOmAGxdsXc7hWsb6wAi)ivrVEvrnN)KCqMU9dyPyFa5nO4OdWUeQIGcLkIMdnvKDvrgnPkYUQyZQy54UPLJN4(mQuugcZ)Wcgm0qpMvCFPH8JeZcURPNm6z4oSD)heJYmb60f2LH)ykK8sgve0QiAQyjv0dvKKlU6Balal4A)o6Q0blmKFQyjv0dvKsKRYPmZnDbFWaVgyOZKaKijh9sg3kdX12osvSKk2Kk6Hkk2VuCagugnWRbPyH9dyPaDlnKFKQOxVQicrT6amOmAGxdsXc7hWsb6iAvrVEvrnN)KCqMU3AybeckuC0byxcvrqRIOxflPIa2EOq5aQiOrPILvZQy54UPLJN4(mQuugcZ)Wcgm0qdZkUV0q(rIzb310tg9mCxSFP4amOmAGxdsXc7hWsb6wAi)ivXsQytQicrT6amOmAGxdsXc7hWsb6iAvrVEvrnN)KCqMU3AybeckuC0byxcvrqRIOxflPIa2EOq5aQiOrPILvZQOxVQiSD)heJYmb60f2LH)ykK8sgveuQyZQyjveHOwDqHtb8V1oQJOvflPIAo)j5GmDV1WcieuO4OdWUeQIGcLkYOjvXYvrVEvrpurX(LIdWGYObEniflSFalfOBPH8Je3nTC8e3NrLIaSGR9JfmyO1mMvCFPH8JeZcURPNm6z4EtQicrT6GcNc4FRDuhDa2LqveuQiCICjd0bft7pGquRJQISRkYOjvr2vfriQvhu4ua)BTJ6GIP9RIE9QIie1QdkCkG)T2rDeTQyjveHOwDagugnWRbPyH9dyPaDeTQy54UPLJN4(FmfsEjtaH)cwWGHg7Gzf3xAi)iXSG7A6jJEgUl2VuCNEvcQVULgYpsvSKkk2VuCagugnWRbPyH9dyPaDlnKFKQyjveHOwDNEvcQVoIwvSKkIquRoadkJg41GuSW(bSuGoIwC30YXtCVs5qjal4A)ybdgAGiMvCFPH8JeZcURPNm6z4ocrT6mOEjPL65iAXDtlhpX93AybeckuWcgm0qhmR4(sd5hjMfCxtpz0ZWDnN)KCqMb6mTOILurpurX(LIdWGYObEniflSFalfOBPH8Je3nTC8e3FRHfqiOqblyWqJ9XSI7lnKFKywWDn9Krpd3f7xkUtVkb1x3sd5hPkwsf9qfBsfbS9qHYburqRISh0rflPIAo)j5GmDV1WcieuO4OdWUeQIGcLkIEvSCC30YXtC)0Rsq9flyWqJ9Gzf3xAi)iXSG7A6jJEgUR58NKdYmqNPfvSKkQlmkZGQiOvrX(LIB6cEGxdsXc7hWsb6wAi)iXDtlhpX93AybeckuWcgm0yVywX9LgYpsml4UMEYONH7I9lf3PxLG6RBPH8JuflPIie1Q70Rsq91r0QILureIA1D6vjO(6OdWUeQIGsfHtKlzGoOyA)beIADuvKDvrgnPkYUQicrT6o9QeuFDqX0(XDtlhpX9kLdLaSGR9JfmyOvwywX9LgYpsml4UMEYONH7Ao)j5Gmd0zAb3nTC8e3FRHfqiOqblyWAg9ywX9LgYpsml4UPLJN4E9nGfGfCTFCxtpz0ZWD6Q0blmKF4U2x9VGyuMjqmyOHfmynJgMvCFPH8JeZcURPNm6z4oSD)heJYmb60f2LH)ykK8sgve0QiAQyjv0dvKsKRYPmZnDbFWaVgyOZKaKijh9sg3kdX12osv0RxveHOwDtxWhmWRbg6mjajsYrVKXr0I7MwoEI7ZOsrzim)dlyWAUzmR4(sd5hjMfCxtpz0ZWDX(LI70Rsq91T0q(rQILureIA1D6vjO(6iAvXsQytQicrT6o9QeuFD0byxcvrqPImAsvKDvrqufzxveHOwDNEvcQVoOyA)QOxVQicrT6GcNc4FRDuhrRk61Rk6Hkk2VuCagugnWRbPyH9dyPaDlnKFKQy54UPLJN4ELYHsawW1(XcgSMzhmR4(sd5hjMfCxtpz0ZWDkrUkNYm3(bSuSpSYqC)Hqpca3kdX12osvSKk6HkIquRU9dyPyFyLH4(dHEeabYHquRoIwvSKk6Hkk2VuC7hWsX(aYBqXT0q(rQILurpurX(LIB6c(Lmbybx73T0q(rI7MwoEI7vkhkbybx7hlyWAgeXSI7MwoEI76c7YqHrBmOG7lnKFKywWcgSMrhmR4(sd5hjMfCxtpz0ZWDX(LIdkMC6a5b1fgLzULgYpsC30YXtChkMC6a5b1fgLzybdwZSpMvCFPH8JeZcURPNm6z4UhQOy)sX1spa7d7hWsX(dkULgYpsv0Rxv0dvSDIRE0f2pGLI9otlxJH7MwoEI7ZOsry)awk2JfmynZEWSI7lnKFKywWDn9Krpd3HT7)GyuMjqNUWUm8htHKxYOIOuXMXDtlhpXDDHDz4pMcjVKblyWAM9Izf3nTC8e3)JPqYlzci8xW9LgYpsmlybdwZLfMvChG34sgmyOH7lnKFbaEJlzWSG7MwoEI713awawW1(XDTV6FbXOmtGyWqd310tg9mCNUkDWcd5hUV0q(rIzblyWyh0Jzf3xAi)iXSG7lnKFbaEJlzWSG7A6jJEgUdWBmGLIJ8GIL6PIGwfzFC30YXtCV(gWcWcU2pUdWBCjdgm0Wcgm2bnmR4oaVXLmyWqd3xAi)ca8gxYGzb3nTC8e3RuoucWcU2pUV0q(rIzblyb3jx1iEbZkgm0WSI7lnKFKywWDYb10RvoEI7OBPmkLOvurEvf1guGoC30YXtChKxsgGfZOybdwZywXDaEJlzWGHgUV0q(fa4nUKbZcUBA54jUdBp6jG0E)JcdmutpCFPH8JeZcwWGXoywXDtlhpX9wUC8e3xAi)iXSGfmyGiMvC30YXtCNaUWjdaI7lnKFKywWcgm0bZkUBA54jUxp6c7hWsXECFPH8JeZcwWGX(ywXDtlhpXDGjJtX9LgYpsmlybdg7bZkUBA54jUdfofiSFalf7X9LgYpsmlybdg7fZkUV0q(rIzb310tg9mChHOwDA7)WFmfsEjJJoa7sOkcAuQiAOh3nTC8e3NVlWRbPybOWPaybdwzHzf3xAi)iXSG7A6jJEgU7Hkk2VuCguVK0s9ClnKFKQOxVQicrT6mOEjPL65iAvrVEvrnN)KCqModQxsAPEo6aSlHQiOvr0b94UPLJN4oYZ5KHkb1xSGbdn0Jzf3xAi)iXSG7A6jJEgU7Hkk2VuCguVK0s9ClnKFKQOxVQicrT6mOEjPL65iAXDtlhpXDKrHJ6)sgSGbdn0WSI7lnKFKywWDn9Krpd39qff7xkodQxsAPEULgYpsv0RxveHOwDguVK0s9CeTQOxVQOMZFsoitNb1ljTuphDa2Lqve0Qi6GEC30YXtCVE0H8CojwWGHwZywX9LgYpsml4UMEYONH7EOII9lfNb1ljTup3sd5hPk61RkIquRodQxsAPEoIwv0RxvuZ5pjhKPZG6LKwQNJoa7sOkcAveDqpUBA54jUBPEqHAFqB)JfmyOXoywX9LgYpsml4UMEYONH7EOII9lfNb1ljTup3sd5hPk61Rk6HkIquRodQxsAPEoIwC30YXtChXyc8AqON2pelyWqdeXSI7lnKFKywWDtlhpX9w6bWPKN9bqAngURPNm6z4UhQicrT6APhaNsE2haP1yoIwCx7R(xqmkZeigm0Wcgm0qhmR4UPLJN4EJbBhniCza4(sd5hjMfSGbdn2hZkUV0q(rIzb310tg9mC3dvuSFP4amOmAGxdsXc7hWsb6wAi)ivrVEvreIA1byqz0aVgKIf2pGLc0r0I7MwoEI7vBbHAjSsapEIfmyOXEWSI7lnKFKywWDn9Krpd3nTCnwy5aUbvrqRInRILuXMury7(pigLzc0PlSld)Xui5LmQiOvXMvrVEvry7(pigLzc09wdlGmdqfbTk2SkwoUBA54jUtjYGPLJNH)GcU)hucPbmC34dlyWqJ9Izf3xAi)iXSG7A6jJEgU7Hkk2VuCqHtbc7hWsXE3sd5hPkwsfnTCnwy5aUbvrqHsfBg3Hc90cgm0WDtlhpXDkrgmTC8m8huW9)GsinGH7Wlz(feJYmblyWqRSWSI7lnKFKywWDn9Krpd3f7xkoOWPaH9dyPyVBPH8JuflPIMwUglSCa3GQiOqPInJ7qHEAbdgA4UPLJN4oLidMwoEg(dk4(FqjKgWWD4cWlz(feJYmblyb3BPtZbqmbZkgm0WSI7lnKFKywWDtlhpX9zuPiSFalf7XDYb10RvoEI7GGY2ttiJufxJr9vfLdyQOumv00cNQIhufTg29gYphURPNm6z4UhQOy)sX1spa7d7hWsX(dkULgYpsSGbRzmR4(sd5hjMfC30YXtChkCkG)T2rXDYb10RvoEI7O7Gtf7cNc4FRDuvSLonhaXevKi)bHQiKdmv0ijHQiiV)vryRbYufHCE6WDn9Krpd3f7xkoOWPa(3Ah1T0q(rQILuXMurQDKH1yP4mssOtZjsrfbLkYoQOxVQi1oYWASuCgjj0DPkcAveDqVkwowWGXoywX9LgYpsml4UMEYONH7I9lf3(bSuSpG8guClnKFK4UPLJN4((bSuSpG8guWcgmqeZkUV0q(rIzb3nTC8e3FRHfqiOqb310tg9mC3dvuSFP42pGLI9bK3GIBPH8Je3)lxqtI7OdwWGHoywX9LgYpsml4UMEYONH70vPdwyi)WDtlhpX96Balal4A)ybdg7Jzf3nTC8e3B5YXtCFPH8JeZcwWcUB8HzfdgAywX9LgYpsml4UMEYONH7ie1QB6c(Lmbybx73r0I7MwoEI7ZOsrzim)dlyWAgZkUBA54jURlSldfgTXGcUV0q(rIzblyWyhmR4(sd5hjMfCxtpz0ZWDX(LIdkCkG)T2rDlnKFK4UPLJN4ou4ua)BTJIfmyGiMvCFPH8JeZcUBA54jUxFdybybx7h310tg9mCNUkDWcd5NkwsfBsfnTCnwGKlU6Balal4A)QiOur2rflPIMwUglSCa3GQiOqPIOJk61RksjYv5uM5G(9fHoZ)OWq9g13a5ao4CRmexB7ivXYXDTV6FbXOmtGyWqdlyWqhmR4(sd5hjMfCxtpz0ZWDpurtlxJfi5IR(gWcWcU2pUBA54jUxFdybybx7hlyWyFmR4(sd5hjMfCxtpz0ZWDX(LIB6c(Lmbybx73T0q(rQILuraBpuOCave0Our2h94UPLJN4(0f8lzcWcU2pwWGXEWSI7lnKFKywWDn9Krpd3f7xkodQxsAPEULgYpsvSKk2Kk6Hk2oXbfofiSFalf7DMwUgtflxflPInPIEOII9lf3PxLG6RBPH8Juf96vf9qfriQv3PxLG6RJOvflPIEOIAo)j5GmDNEvcQVoIwvSCC30YXtC3G6LKwQhwWGXEXSI7lnKFKywWDn9Krpd3f7xkU)kdXrgamgaliCzaULgYpsC30YXtC)VYqCKbaJbWccxgawWGvwywX9LgYpsml4UMEYONH7uICvoLzUPl4dg41adDMeGej5OxY4wziU22rQILurpureIA1nDbFWaVgyOZKaKijh9sghrlUBA54jUpJkfbybx7hlyWqd9ywX9LgYpsml4UMEYONH7uICvoLzoYTwHoaonafEo3kdX12osvSKk2Kk6Hkk2VuCT0dW(W(bSuS)GIBPH8Juf96vfBsf9qfBN4GcNce2pGLI9otlxJPILurpuX2jU6rxy)awk27mTCnMkwUkwoUBA54jUpJkfH9dyPypwWGHgAywX9LgYpsml4UPLJN4(BnSacbfk4UMEYONH7W29FqmkZeOtxyxg(JPqYlzurqPIGOk61RkIquRU3AybibLzoIwv0RxvSjvuSFP4amOmAGxdsXc7hWsb6wAi)ivXsQOhQicrT6amOmAGxdsXc7hWsb6iAvXsQiGThkuoGkcAuQi7JEvSCCx7R(xqmkZeigm0Wcgm0AgZkUV0q(rIzb3nTC8e3NrLIYqy(hUtoOMETYXtCNvQVQOWvrgdyQiiWOsrzim)tfb5jfQi6QbLrvrEvfLIPIGGFalfOkIquRQiilwQI1JPqUKrfzhvumkZeOtfl7WZYErf5ngvBTQi6QThkuoGh4UMEYONH7EOII9lfhGbLrd8Aqkwy)awkq3sd5hPk61RkIquRoOWPa(3Ah1r0QIE9QIa2EOq5aQiOrPInPIOHE0RILnQiiQISRkcB3)bXOmtGoDHDz4pMcjVKrflxf96vfriQvhGbLrd8Aqkwy)awkqhrRk61RkcB3)bXOmtGoDHDz4pMcjVKrfbTkYoybdgASdMvCFPH8JeZcUBA54jURlSld)Xui5Lm4o5GA61khpXD0vZ)uribDQOVCcvKKNL9Ik(C4urtf7cNc4FRDuveHOwD4UMEYONH7ie1QdkCkG)T2rD0byxcvrqPISJkYUQiJMufzxveHOwDqHtb8V1oQdkM2pwWGHgiIzf3xAi)iXSG7MwoEI7V1WcieuOG7KdQPxRC8e3rxKVVQO2GIkw21AyQileuOOI8ufLc6MkkgLzcufVQkEIkEqv0sv8sOyPOIwsQIDHtburqWpGLI9Q4bvrWqxWQkAA5AmhURPNm6z4ocrT6ERHfGeuM5iAvXsQiSD)heJYmb60f2LH)ykK8sgveuQiiQILuXMurpuX2joOWPaH9dyPyVZ0Y1yQy5QyjvKKlU6Balal4A)o50(VKblyWqdDWSI7lnKFKywWDtlhpX99dyPyFa5nOG7KdQPxRC8e3r3bNkcc(bSuSxfz5nOOIgJDjuurIwvu4Qi7OIIrzMavrdQIppzurdQIDHtburqWpGLI9Q4bvXKlQOPLRXC4UMEYONH7I9lf3(bSuSpG8guClnKFKQyjve2U)dIrzMaD6c7YWFmfsEjJkckveDuXsQytQOhQy7ehu4uGW(bSuS3zA5AmvSCSGbdn2hZkUV0q(rIzb310tg9mCxSFP4mOEjPL65wAi)iXDtlhpX93AybKzaybdgAShmR4UPLJN4UUWUm8htHKxYG7lnKFKywWcgm0yVywX9LgYpsml4(sd5xaG34sgml4UMEYONH7ie1Q7TgwasqzMJOvflPIAo)j5Gmd0zAb3nTC8e3FRHfqiOqb3b4nUKbdgAybdgALfMvChG34sgmyOH7lnKFbaEJlzWSG7MwoEI713awawW1(XDTV6FbXOmtGyWqd310tg9mCNUkDWcd5hUV0q(rIzblyWAg9ywXDaEJlzWGHgUV0q(fa4nUKbZcUBA54jUxPCOeGfCTFCFPH8JeZcwWcUdxaEjZVGyuMjywXGHgMvCFPH8JeZcUBA54jUxFdybybx7h310tg9mCVjvKoa7sOkckuQiJMuflxflPInPIie1Q7TgwasqzMJOvf96vf9qfriQvhYZ5KpbuCeTQy54U2x9VGyuMjqmyOHfmynJzf3xAi)iXSG7A6jJEgUl2VuC7hWsX(aYBqXT0q(rI7MwoEI77hWsX(aYBqblyWyhmR4(sd5hjMfCxtpz0ZWDX(LIdkCkG)T2rDlnKFKQyjvSjveW2dfkhqfbLkcIGOkwoUBA54jUdfofW)w7OybdgiIzf3xAi)iXSG7A6jJEgUl2VuCtxWVKjal4A)ULgYpsC30YXtCF6c(Lmbybx7hlyWqhmR4(sd5hjMfCxtpz0ZWDeIA1bYljdmeqXbft7xfbLkIg7vf96vfriQv3BnSaKGYmhrlUBA54jU)wdlGqqHcwWGX(ywX9LgYpsml4UMEYONH7ie1QdkCkG)T2rDeT4UPLJN4(FmfsEjtaH)cwWGXEWSI7lnKFKywWDn9Krpd3riQv30f8bd8AGHotcqIKC0lzCeT4UPLJN4(mQuugcZ)Wcgm2lMvCFPH8JeZcURPNm6z4EtQiSD)heJYmb60f2LH)ykK8sgve0QiAQy5QyjvSjv0dvKKlU6Balal4A)o6Q0blmKFQy54UPLJN4(mQuugcZ)WcgSYcZkUV0q(rIzb310tg9mCh2U)dIrzMaD6c7YWFmfsEjJkckvSzvSKkcy7HcLdOIGgLkY(OxflPInPIie1QdKxsgyiGIdkM2VkckvSz0RIE9QIa2EOq5aQiOvXYc9Qy5QOxVQytQiLixLtzMB6c(GbEnWqNjbirso6LmUvgIRTDKQyjv0dveHOwDtxWhmWRbg6mjajsYrVKXr0QILJ7MwoEI7ZOsrawW1(Xcgm0qpMvCFPH8JeZcURPNm6z4EtQicrT6GcNc4FRDuhDa2LqveuQiCICjd0bft7pGquRJQISRkYOjvr2vfriQvhu4ua)BTJ6GIP9RIE9QIie1QdkCkG)T2rDeTQyjveHOwDagugnWRbPyH9dyPaDeTQy54UPLJN4(FmfsEjtaH)cwWGHgAywX9LgYpsml4UMEYONH7I9lf3PxLG6RBPH8JuflPII9lfhGbLrd8Aqkwy)awkq3sd5hPkwsfriQv3PxLG6RJOvflPIie1QdWGYObEniflSFalfOJOf3nTC8e3RuoucWcU2pwWGHwZywX9LgYpsml4UMEYONH7ie1QZG6LKwQNJOf3nTC8e3FRHfqiOqblyWqJDWSI7lnKFKywWDn9Krpd31C(tYbzgOZ0Ikwsf9qff7xkoadkJg41GuSW(bSuGULgYpsC30YXtC)TgwaHGcfSGbdnqeZkUV0q(rIzb310tg9mCxSFP4o9QeuFDlnKFKQyjv0dvSjveW2dfkhqfbTkYEqhvSKkQ58NKdY09wdlGqqHIJoa7sOkckuQi6vXYXDtlhpX9tVkb1xSGbdn0bZkUV0q(rIzb310tg9mCxZ5pjhKzGotlQyjvuxyuMbvrqRII9lf30f8aVgKIf2pGLc0T0q(rI7MwoEI7V1WcieuOGfmyOX(ywX9LgYpsml4UMEYONH7I9lf3PxLG6RBPH8JuflPIie1Q70Rsq91r0I7MwoEI7vkhkbybx7hlyWqJ9Gzf3nTC8e31f2LHcJ2yqb3xAi)iXSGfmyOXEXSI7lnKFKywWDn9Krpd3f7xkoOyYPdKhuxyuM5wAi)iXDtlhpXDOyYPdKhuxyuMHfmyOvwywX9LgYpsml4UMEYONH7EOII9lfxl9aSpSFalf7pO4wAi)ivrVEvrX(LIRLEa2h2pGLI9huClnKFKQyjvSjv0dvSDIdkCkqy)awk27mTCnMkwoUBA54jUpJkfH9dyPypwWG1m6XSI7lnKFKywWDn9Krpd3HT7)GyuMjqNUWUm8htHKxYOIOuXMXDtlhpXDDHDz4pMcjVKblyWAgnmR4UPLJN4(FmfsEjtaH)cUV0q(rIzblyWAUzmR4oaVXLmyWqd3xAi)ca8gxYGzb3nTC8e3RVbSaSGR9J7AF1)cIrzMaXGHgURPNm6z4oDv6GfgYpCFPH8JeZcwWG1m7Gzf3xAi)iXSG7lnKFbaEJlzWSG7A6jJEgUdWBmGLIJ8GIL6PIGwfzFC30YXtCV(gWcWcU2pUdWBCjdgm0WcgSMbrmR4oaVXLmyWqd3xAi)ca8gxYGzb3nTC8e3RuoucWcU2pUV0q(rIzblybl4UrifCkU3paI3KJNLTOwvWcwWya]] )

end
