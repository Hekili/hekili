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
        grounding_totem = 3620, -- 204336
        lightning_lasso = 731, -- 305483
        seasoned_winds = 5415, -- 355630
        skyfury_totem = 3488, -- 204330
        spectral_recovery = 3062, -- 204261
        static_field_totem = 727, -- 355580
        swelling_waves = 3621, -- 204264
        traveling_storms = 730, -- 204403
        unleash_shield = 3491, -- 356736
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

                if buff.primordial_wave.up and state.spec.elemental and legendary.splintered_elements.enabled then
                    applyBuff( "splintered_elements", nil, active_dot.flame_shock )
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
            gcd = "totem",

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
            velocity = 45,

            handler = function ()
                applyDebuff( "target", "flame_shock" )
                applyBuff( "primordial_wave" )
            end,

            auras = {
                primordial_wave = {
                    id = 327164,
                    duration = 15,
                    max_stack = 1
                },
                splintered_elements = {
                    id = 354648,
                    duration = 10,
                    max_stack = 10,
                },
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

            tick = function ()
                if legendary.seeds_of_rampant_growth.enabled then
                    if state.spec.enhancement then reduceCooldown( "feral_spirit", 7 )
                    elseif state.spec.elemental then reduceCooldown( talent.storm_elemental.enabled and "storm_elemental" or "fire_elemental", 6 )
                    else reduceCooldown( "healing_tide_totem", 5 ) end
                    addStack( "seeds_of_rampant_growth" )
                end
            end,

            finish = function ()
                if state.spec.enhancement then addStack( "maelstrom_weapon", nil, 3 ) end
            end,

            auras = {
                fae_transfusion = {
                    id = 328933,
                    duration = 20,
                    max_stack = 1
                },
                seeds_of_rampant_growth = {
                    id = 358945,
                    duration = 15,
                    max_stack = 5
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

            handler = function ()
                if legendary.elemental_conduit.enabled then                    
                    applyDebuff( "target", "flame_shock" )
                    active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + min( 5, active_enemies ) )
                end
            end,
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

    spec:RegisterPack( "Elemental", 20210627, [[dauD7bqiuPEeKOytqQrjL4ucvTkuvYReknlHOBHQsj7cPFjummujDmbXYKs6zqImniP6AqszBOQOVHQcghQk05GevRdvLsnpHk3dvSpiHdcjkPfki9qirjUiQkvojQkfRevPBcjkv7evXtr0ufcxfsuk7LWFrzWICyQwmepMstgHlRSzr9zvz0cCAvETGA2a3wvTBj)MOHlfhhvILd1ZbnDsxxQ2UuQVdjz8OQu15rv18fs7NIfHiIqqs46e80kxBneUYNTYhOHWhqDuokHYfKk)ntq242W(BcYY)tqY3b2FL6abzJZpq6eIieKqzhBNGmq1giF7yI5DAqhHAL)yG3VdC9KLf7zng49TXiir6hq5BkbIGKW1j4PvU2AiCLpBLpqdHpG6OCuIpkiHnZk4Pv(SvbzWrqSsGiijg0ki57a7VsDGjrg4FVm8YBVMj1kFistQvU2AigEn8IYsGxVb5BB4LVLjX3uwjUrIDDMeCQE1dsHQBdZq658WMuwInj(g7YDm)rAsKQe)dV1mm1WlFltcLvcctcL9PtInjVimj(o(NjjZMKgmtIuL4Vj5p)kQGSblZhycsugugtIVdS)k1bMezG)9YWlkdkJjXBVMj1kFistQvU2AigEn8IYGYysOSe41Bq(2gErzqzmj(wMeFtzL4gj21zsWP6vpifQUnmdPNZdBszj2K4BSl3X8hPjrQs8p8wZWudVOmOmMeFltcLvcctcL9PtInjVimj(o(NjjZMKgmtIuL4Vj5p)kQHxdVOmMeFhF)SDDeM0Apm)MKE)zsAWmj3QsSjDqtYB7hWraJA41T6jliTbpR8J4kN5ynGnW(Ruhe5L5WT6GvkTbFFhWgy)vQdoOsx5iGry4fLXKqzdotIuL4F4TMHnPg8SYpIRMuVadcnjO8ptYjiGMeQoaWKGnoQktckLf1WRB1twqAdEw5hX1y5eduL4F4TMHJ8YCuhSsPqvI)H3AgMUYraJaDly)iyR9kL6eeqQv2lnoukAuSFeS1ELsDcci9kuGACnEdVUvpzbPn4zLFexJLtm5dp2a7VsDGHx3QNSG0g8SYpIRXYjMb2FL6agcWHAKxMJ6GvkDG9xPoGHaCOsx5iGrGg2maGPo(nfsTb(vmW9c06QxCOKHx3QNSG0g8SYpIRXYjgG32ziDmuJ8YC4wDWkLoW(RuhWqaouPRCeWiqdBgaWuh)McP2a)kg4EbAD1loukAuKEotHQe)dV1mmT3y41T6jliTbpR8J4ASCIXg4xXa3lqRRErEzoCRoyLshy)vQdyiahQ0vocyeOHndayQJFtHuBGFfdCVaTU6HcoOeAUr65mfQs8p8wZW0EJHx3QNSG0g8SYpIRXYjMgPEYYWRHxugtIVP0HX9g1KKztY6qfsn86w9KfmwoXGQRiyWG5ydVUvpzbJLtmWMdFkQCq4HHSh2TlYVS9vpoHy41T6jlySCIPrQNSm86w9KfmwoX0HJD6(qdVUvpzbJLtmzG)hdgiTHJ8YCAHB1bRu6a7VsDadb4qLUYraJiE0CRNn8vp0C3mLcvj(Zgy)vQdOUvV2dDlWMbam1XVPqQnWVIbUxGwx9IdLIgvDWkL(DOomtMzAWydS)kfsx5iGrenkUxllXVrHH5hbpp8Wqw(gMFgX(hC0XL(10mI4n86w9KfmwoX0GVVetCoGHkV9I0YVfmM643uiNqI8YC4gPNZ0g89LyIZbmu5ThT3GUfUBMsHQe)zdS)k1bu3Qx7fnkSzaatD8BkKAd8RyG7fO1vV4qj0i9CMIQRiyVouPq1THJRvUgnku2bixrqbZjyi8ZgFV)BaJUYraJiE0TaBgaWuh)McP2a)kg4EbAD1loulAu1bRu63H6WmzMPbJnW(RuiDLJagr0O4ETSe)gfgMFe88Wddz5By(ze7FWrhx6xtZiIgfk7aKRiOG5eme(zJV3)nGrx5iGreVHx3QNSGXYjMmW)JbdK2WrEzoCRNn8vp0TWDZukuL4pBG9xPoG6w9AVOrHndayQJFtHuBGFfdCVaTU6fhkHgPNZuuDfb71HkfQUnCCTY14r3cSzaatD8BkKAd8RyG7fO1vV4qPOrvhSsPFhQdZKzMgm2a7VsH0vocyerJI71Ys8Buyy(rWZdpmKLVH5NrS)bhDCPFnnJiEdVUvpzbJLtm5dp2a7VsDGHx3QNSGXYjM)0jXgEDREYcglNyqasjbl3X8h5L5WT6Gvk1H2veEzhDLJagr0Oi9CM6q7kcVSJ2BIg1kLacjQkQdTRi8YokEF)kikqnUA41T6jlySCIbzy4WHV6f5L5WT6Gvk1H2veEzhDLJagr0Oi9CM6q7kcVSJ2Bm86w9KfmwoXKp8qasjrKxMd3QdwPuhAxr4LD0vocyerJI0ZzQdTRi8YoAVjAuRuciKOQOo0UIWl7O499RGOa14QHx3QNSGXYjgVSdQyhWSoae5L5WT6Gvk1H2veEzhDLJagr0Oi9CM6q7kcVSJ2BIg1kLacjQkQdTRi8YokEF)kikqnUA41T6jlySCIbXFmzMP4Zggg5L5WT6Gvk1H2veEzhDLJagr0OCJ0ZzQdTRi8YoAVXWRB1twWy5et7bBgMPsDFdVUvpzbJLtmzFmf7fm3HNSI8YCSY2R8sP19cuw2h6w4wDWkL(DOomtMzAWydS)kfsx5iGrenkspNPFhQdZKzMgm2a7VsH0Et8OHndayQJFtHuBGFfdCVaTU6fhkz41T6jlySCIb3lMB1twmWb1il)poUCrEzoUvV2JTA)Bqu0k6wGndayQJFtHuBGFfdCVaTU6HIwJgf2maGPo(nfsbEBNHm)JIwJ3WRB1twWy5edUxm3QNSyGdQrw(FCGx9aJPo(nnsOIpRYjKiVmhUvhSsPqvI)Sb2FL6a6khbmc0UvV2JTA)BW440QHx3QNSGXYjgCVyUvpzXahuJS8)4ahdE1dmM6430iHk(SkNqI8YCuhSsPqvI)Sb2FL6a6khbmc0UvV2JTA)BW440QHxdVUvpzbPUCCGQe)zdS)k1bgEDREYcsD5ILtmJ)XKzMgmguL4FKxMdspNPwhayG7fO1vpkEF)kik4ecxn86w9KfK6YflNyMJ1aU09WlYlZbPNZ0zdKx9yWaPnmT3y41T6jli1LlwoXyd8RyboU9GQHx3QNSGuxUy5eduL4F4TMHJ8YCuhSsPqvI)H3AgMUYraJWWRB1twqQlxSCIjd8)yWaPnCKw(TGXuh)Mc5esKxMdEz8GbocyOBPf3Qx7XiKknd8)yWaPnCCTI2T61ESv7FdghhucTvkbesuv0g89LyIZbmu5ThfVVFfmUq4t0wz7vEP0AwSeiXeO5UzkfQs8NnW(RuhqDRETx0OUvV2JrivAg4)XGbsB44cbTB1R9yR2)gefCqD0C3mLcvj(Zgy)vQdOUvV2dT6Gvk97qDyMmZ0GXgy)vkKUYraJi(OrBb3RLL43OWW8JGNhEyilFdZpJy)do64s)AAgbAUBMsHQe)zdS)k1bu3Qx7fF8gEDREYcsD5ILtmzG)hdgiTHJ8YC42T61EmcPsZa)pgmqAdJM7MPuOkXF2a7VsDa1T61EOBrDWkL(DOomtMzAWydS)kfsx5iGrenkUxllXVrHH5hbpp8Wqw(gMFgX(hC0XL(10mI4n86w9KfK6YflNyMnqE1JbdK2WrEzoQdwP0zdKx9yWaPnmDLJagb6VpauXYpk4WNCfDl4ETSe)gD2a5GmzM9WZvgSxedF1JoU0VMMrGgPNZ0zdKdYKz2dpxzWErm8vpAVjAuUX9Azj(n6SbYbzYm7HNRmyVig(QhDCPFnnJiEdVUvpzbPUCXYjghAxr4LDrEzoQdwPuhAxr4LD0vocyeOBH7MPuOkXF2a7VsDa1T61EXJUfUvhSsPND5oMF6khbmIOr5gPNZ0ZUChZpT3GMBRuciKOQOND5oMFAVjEdVUvpzbPUCXYjgWXL(rW((77mvQ7h5L5OoyLsbhx6hb77VVZuPUpDLJagHHx3QNSGuxUy5eJnWVIbUxGwx9I8YCGndayQJFtHuBGFfdCVaTU6fhQJgPNZ0Vd1HzYmtdgBG9xPqAVb93haQy5pouJRgEDREYcsD5ILtmZXAadgiTHJ8YCW9Azj(n6SbYbzYm7HNRmyVig(QhDCPFnnJan3i9CMoBGCqMmZE45kd2lIHV6r7ngEDREYcsD5ILtmaVTZq6yOg5L5qivAg4)XGbsBykEF)kiAyZaaM643ui1g4xXa3lqRREXH6OBH7MPuOkXF2a7VsDa1T61EXJUfKEotbEBNb743O9g0CJ0Zz63H6WmzMPbJnW(RuiT3GwDWkL(DOomtMzAWydS)kfsx5iGreVHx3QNSGuxUy5eZCSgWLUhErEzoWMbam1XVPqQnWVIbUxGwx9qbNwrZnUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzeOBrDWkL(DOomtMzAWydS)kfsx5iGrG(7davS8JcoOgxrZnspNPFhQdZKzMgm2a7VsH0Et8gEDREYcsD5ILtmaVTZq6yOg5L5qivAg4)XGbsBykEF)kiAKEotbEBNb743O9g0i9CM2GVVetCoGHkV9O9gdVUvpzbPUCXYjgG32ziDmuJ8YCiKknd8)yWaPnmfVVFfenSzaatD8BkKAd8RyG7fO1vV4qD04ETSe)gfgMFe88Wddz5By(ze7FWrhx6xtZiqJ0ZzkWB7myh)gT3GwDWkL(DOomtMzAWydS)kfsx5iGrGMBKEot)ouhMjZmnySb2FLcP9g0FFaOILFuWb14QHx3QNSGuxUy5edWB7mKogQrEzoesLMb(FmyG0gMI33VcIULwGndayQJFtHuBGFfdCVaTU6fhQJg3RLL43OWW8JGNhEyilFdZpJy)do64s)AAgbA1bRu63H6WmzMPbJnW(RuiDLJagr8rJ2I6Gvk97qDyMmZ0GXgy)vkKUYraJa93haQy5hfCqnUIMBKEot)ouhMjZmnySb2FLcP9g0TWnUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzerJI0Zz6SbYbzYm7HNRmyVig(QhT3epAUX9Azj(nkmm)i45HhgYY3W8Zi2)GJoU0VMMreF8gEDREYcsD5ILtmaVTZq6yOg5L5qivAg4)XGbsBykEF)kiAyZaaM643ui1g4xXa3lqRRECqD04ETSe)gfgMFe88Wddz5By(ze7FWrhx6xtZiqJ0ZzkWB7myh)gT3GwDWkL(DOomtMzAWydS)kfsx5iGrGMBKEot)ouhMjZmnySb2FLcP9g0FFaOILFuWb14QHx3QNSGuxUy5eZCSgWLUhErEzoWMbam1XVPqQnWVIbUxGwx9qbNwn86w9KfK6YflNySb(vmW9c06QxKxMdspNPqvI)H3AgMI33VcghkXxplbFH0ZzkuL4F4TMHPq1THn86w9KfK6YflNyaEBNH0XqnYlZbPNZuG32zWo(nAVbnSzaatD8BkKAd8RyG7fO1vV4qD0TWDZukuL4pBG9xPoG6w9AV4rtivAg4)XGbsByQE2Wx9m86w9KfK6YflNygy)vQdyiahQrEzoQdwP0b2FL6agcWHkDLJagbAyZaaM643ui1g4xXa3lqRREXHAOBH7MPuOkXF2a7VsDa1T61EXB41T6jli1LlwoXa82odz(pYlZrDWkL6q7kcVSJUYraJWWRB1twqQlxSCIXg4xXa3lqRREgEDREYcsD5ILtmaVTZq6yOg5x2(QhNqI8YCq65mf4TDgSJFJ2BqBLsaHevfdp3QgEDREYcsD5ILtmzG)hdgiTHJ8lBF1JtirA53cgtD8BkKtirEzo4LXdg4iGz41T6jli1LlwoXKXsOYGbsB4i)Y2x94eIHxdVUvpzbPWXGx9aJPo(nLduL4pBG9xPoWWRB1twqkCm4vpWyQJFtJLtmJ)XKzMgmguL4FKxMdspNPwhayG7fO1vpkEF)kik4ecxn86w9KfKchdE1dmM6430y5etglHkdgiTHJ8YCuhSsPND5oMF6khbmc0i9CME2L7y(P9g0i9CME2L7y(P499RGXbNQx9GuO62WmKEopmF9Se8fspNPND5oMFkuDBy0i9CMIQRiyVouPq1THJle(OHx3QNSGu4yWREGXuh)MglNygy)vQdyiahQrEzoQdwP0b2FL6agcWHkDLJagHHx3QNSGu4yWREGXuh)MglNyGQe)dV1mCKxMJ6GvkfQs8p8wZW0vocyegEDREYcsHJbV6bgtD8BASCIz2a5vpgmqAdh5L5OoyLsNnqE1JbdK2W0vocyeOTsjGqIQIc82odPJHkfVVFfmooplbAyZaaM643ui1g4xXa3lqRREX1A0OFFaOILFuWHp5kAyZaaM643ui1g4xXa3lqRREOGtROBHBCVwwIFJoBGCqMmZE45kd2lIHV6rhx6xtZiIgfPNZ0zdKdYKz2dpxzWErm8vpAVj(OrHndayQJFtHuBGFfdCVaTU6fxROr65mfvxrWEDOsHQBdJcoHWhr3c34ETSe)gD2a5GmzM9WZvgSxedF1JoU0VMMrenkspNPZgihKjZShEUYG9Iy4RE0Et8O)(aqfl)OGdFYvdVUvpzbPWXGx9aJPo(nnwoXa82odPJHAKxMtli9CMIQRiyVouPq1THJle(iAUr65mfbiLeGouP9M4JgfPNZuG32zWo(nAVXWRB1twqkCm4vpWyQJFtJLtmaVTZq6yOg5L5OoyLsNnqE1JbdK2W0vocyeOr65mD2a5vpgmqAdt7nOHndayQJFtHuBGFfdCVaTU6fxRgEDREYcsHJbV6bgtD8BASCIzowd4s3dViVmh1bRu6SbYREmyG0gMUYraJanspNPZgiV6XGbsByAVbnSzaatD8BkKAd8RyG7fO1vpuWPvdVUvpzbPWXGx9aJPo(nnwoXaUxGwx9yisGg5L5G0ZzkuL4F4TMHP9gdVUvpzbPWXGx9aJPo(nnwoXmhRbCP7HxKxMdspNPZgihKjZShEUYG9Iy4RE0EJHx3QNSGu4yWREGXuh)MglNyMJ1agmqAdh5L5aBgaWuh)McP2a)kg4EbAD1lUwr)9bGkw(rbh(KROBbPNZuuDfb71HkfQUnCCTY1Or)(aqfl)OaLZ14JgTfCVwwIFJoBGCqMmZE45kd2lIHV6rhx6xtZiqZnspNPZgihKjZShEUYG9Iy4RE0Et8gEDREYcsHJbV6bgtD8BASCIzowd4s3dViVmNwGndayQJFtHuBGFfdCVaTU6HIqIhDlCtivAg4)XGbsBykEz8GbocyXB41T6jlifog8Qhym1XVPXYjgBGFfdCVaTU6f5L54w9Ap2Q9VbrriOBMsHQe)zdS)k1bu3Qx7HgPNZueGusa6qL2Bm86w9KfKchdE1dmM6430y5ed4EbAD1JHibAKxMtZukuL4pBG9xPoG6w9Ap0i9CMIaKscqhQ0EJHx3QNSGu4yWREGXuh)MglNyaEBNH0XqnYlZbPNZuhAxr4LD0EJHx3QNSGu4yWREGXuh)MglNyaEBNH0XqnYlZXkLacjQkgEUvn86w9KfKchdE1dmM6430y5edWB7mKogQrEzowPeqirvXWZTkABGJFdIc1bRu6SbsMmZ0GXgy)vkKUYraJWWRB1twqkCm4vpWyQJFtJLtmzSeQmyG0goYlZrDWkLE2L7y(PRCeWiqJ0Zz6zxUJ5N2Bm86w9KfKchdE1dmM6430y5eJnWVIf442dQgEDREYcsHJbV6bgtD8BASCIbQUEwgXbTbo(TiVmh1bRukuD9SmIdAdC8B0vocyegEDREYcsHJbV6bgtD8BASCIzowdydS)k1brEzoCRoyLsBW33bSb2FL6GdQ0vocyerJQoyLsBW33bSb2FL6GdQ0vocyeOBH7MPuOkXF2a7VsDa1T61EXB41T6jlifog8Qhym1XVPXYjgBGFfdCVaTU6f5L54w9Ap2Q9VbrriOBb2maGPo(nfsTb(vmW9c06QhkcjAuyZaaM643uif4TDgY8pkcjEdVUvpzbPWXGx9aJPo(nnwoXaUxGwx9yisGA41T6jlifog8Qhym1XVPXYjMmW)JbdK2Wr(LTV6XjKiT8BbJPo(nfYjKiVmh8Y4bdCeWm86w9KfKchdE1dmM6430y5etg4)XGbsB4i)Y2x94esKxMZx2E)vkL4GQx2Hc(0WRB1twqkCm4vpWyQJFtJLtmzSeQmyG0goYVS9vpoHy41WRB1twqk8Qhym1XVPCa3lqRREmejqJ8YCAbPNZuOkX)WBndtX77xbJdovV6bPq1THzi9CEy(6zj4lKEotHQe)dV1mmfQUnC8gEDREYcsHx9aJPo(nnwoXKXsOYGbsB4iVmh1bRu6zxUJ5NUYraJanspNPND5oMFAVbnspNPND5oMFkEF)kyCWP6vpifQUnmdPNZdZxplbFH0Zz6zxUJ5Ncv3g2WRB1twqk8Qhym1XVPXYjMmW)JbdK2WrA53cgtD8BkKtirEzoTWTE2Wx9IgLqQ0mW)JbdK2Wu8((vW448SerJQoyLsDODfHx2rx5iGrGMqQ0mW)JbdK2Wu8((vW4AXkLacjQkQdTRi8YokEF)kySi9CM6q7kcVSJs0XUEYkE0wPeqirvrDODfHx2rX77xbJd1JhDli9CMc82od2XVr7nrJYnspNPiaPKa0HkT3eVHx3QNSGu4vpWyQJFtJLtmzG)hdgiTHJ0YVfmM643uiNqI8YCq65mTbFFjM4CadvE7r7nOXlJhmWraZWRB1twqk8Qhym1XVPXYjghAxr4LDrEzoQdwPuhAxr4LD0vocyeOBrV)qbh(KRrJI0ZzkcqkjaDOs7nXJUfRuciKOQOaVTZq6yOsX77xbrbxJhDlCRoyLsp7YDm)0vocyerJYnspNPND5oMFAVbn3wPeqirvrp7YDm)0Et8gEDREYcsHx9aJPo(nnwoXa82odPJHAKxMdspNPaVTZGD8B0Ed6wW9Azj(nkQUIa2mp8WqgWB7m8GD8BLD0XL(10mIOr5gPNZ0Vd1HzYmtdgBG9xPqAVbT6Gvk97qDyMmZ0GXgy)vkKUYraJiEdVUvpzbPWREGXuh)MglNygy)vQdyiahQrEzoQdwP0b2FL6agcWHkDLJagb6w((aqfl)XXh4A8gEDREYcsHx9aJPo(nnwoXavj(hERz4iVmh1bRukuL4F4TMHPRCeWiq3c2pc2AVsPobbKAL9sJdLIgf7hbBTxPuNGasVcfOgxJhDlFFaOIL)4qDupEdVUvpzbPWREGXuh)MglNyMnqE1JbdK2WrEzoQdwP0zdKx9yWaPnmDLJagbARuciKOQOaVTZq6yOsX77xbJJZZsy41T6jlifE1dmM6430y5edWB7mKogQrEzoQdwP0zdKx9yWaPnmDLJagbAKEotNnqE1JbdK2W0EJHx3QNSGu4vpWyQJFtJLtmGJl9JG9933zQu3pYlZrDWkLcoU0pc23FFNPsDF6khbmcdVUvpzbPWREGXuh)MglNyMJ1aU09WlYlZbPNZ0zdKdYKz2dpxzWErm8vpAVbT6Gvk97qDyMmZ0GXgy)vkKUYraJanspNPFhQdZKzMgm2a7VsH0EJHx3QNSGu4vpWyQJFtJLtmG7fO1vpgIeOrEzoi9CMcvj(hERzyAVbnspNPFhQdZKzMgm2a7VsH0Ed6VpauXYFC8jxn86w9KfKcV6bgtD8BASCIzowd4s3dViVmhKEotNnqoitMzp8CLb7fXWx9O9g0TOoyLs)ouhMjZmnySb2FLcPRCeWiq3cspNPFhQdZKzMgm2a7VsH0Et0OwPeqirvrbEBNH0XqLI33VcIcUI(7davS8JcoO8wJgf2maGPo(nfsTb(vmW9c06QxCTIgPNZuOkX)WBndt7nOTsjGqIQIc82odPJHkfVVFfmooplr8rJYT6Gvk97qDyMmZ0GXgy)vkKUYraJiAuRuciKOQOdS)k1bmeGdvkEF)kyCCGt1REqkuDBygspNhMVEwc(Q14n86w9KfKcV6bgtD8BASCIzowd4s3dViVmhyZaaM643ui1g4xXa3lqRREOie0CtivAg4)XGbsBykEz8GbocyO5g3RLL43OZgihKjZShEUYG9Iy4RE0XL(10mc0TWT6Gvk97qDyMmZ0GXgy)vkKUYraJiAuKEot)ouhMjZmnySb2FLcP9MOrTsjGqIQIc82odPJHkfVVFfefCf93haQy5hfCq5TgVHx3QNSGu4vpWyQJFtJLtmaVTZq6yOg5L5yLsaHevfdp3QOBHBKEot)ouhMjZmnySb2FLcP9g0i9CME2L7y(P9M4n86w9KfKcV6bgtD8BASCIb4TDgshd1iVmhRuciKOQy45wfTnWXVbrH6GvkD2ajtMzAWydS)kfsx5iGrGMBKEotp7YDm)0EJHx3QNSGu4vpWyQJFtJLtmaVTZq6yOg5L5OoyLsNnqYKzMgm2a7VsH0vocyeO5gPNZ0Vd1HzYmtdgBG9xPqAVb93haQy5hfCqnUIMBKEotNnqoitMzp8CLb7fXWx9O9gdVUvpzbPWREGXuh)MglNyMJ1agmqAdh5L50cUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzerJcBgaWuh)McP2a)kg4EbAD1lUwJhDlQdwP0Vd1HzYmtdgBG9xPq6khbmc0CJ0Zz6SbYbzYm7HNRmyVig(QhT3GUfKEot)ouhMjZmnySb2FLcP9MOr)(aqfl)OGdkV1OrHndayQJFtHuBGFfdCVaTU6fxROr65mfQs8p8wZW0EdARuciKOQOaVTZq6yOsX77xbJJZZseF0OCRoyLs)ouhMjZmnySb2FLcPRCeWiIg1kLacjQk6a7VsDadb4qLI33Vcghh4u9QhKcv3gMH0Z5H5RNLGVAnEdVUvpzbPWREGXuh)MglNyYyjuzWaPnCKxMJ6Gvk9Sl3X8tx5iGrGwDWkL(DOomtMzAWydS)kfsx5iGrGgPNZ0ZUChZpT3GgPNZ0Vd1HzYmtdgBG9xPqAVXWRB1twqk8Qhym1XVPXYjgG32ziDmuJ8YCq65m1H2veEzhT3y41T6jlifE1dmM6430y5edWB7mKogQrEzowPeqirvXWZTkAUvhSsPFhQdZKzMgm2a7VsH0vocyegEDREYcsHx9aJPo(nnwoXC2L7y(J8YCuhSsPND5oMF6khbmc0C3Y3haQy5hfOeQH2kLacjQkkWB7mKogQu8((vW44W14n86w9KfKcV6bgtD8BASCIjJLqLbdK2WrEzoQdwP0ZUChZpDLJagbAKEotp7YDm)0Ed6wq65m9Sl3X8tX77xbJ7zj4luNVq65m9Sl3X8tHQBdhnkspNPqvI)H3AgM2BIgLB1bRu63H6WmzMPbJnW(RuiDLJagr8gEDREYcsHx9aJPo(nnwoXa82odPJHQHx3QNSGu4vpWyQJFtJLtmzG)hdgiTHJ0YVfmM643uiNqI8YCWlJhmWraZWRB1twqk8Qhym1XVPXYjMmwcvgmqAdh5L5G71Ys8B0b2FL6a24s)ahc(6F64s)AAgbAUr65mDG9xPoGnU0pWHGV(NrmKEot7nO5wDWkLoW(RuhWqaouPRCeWiqZT6GvkD2a5vpgmqAdtx5iGry41T6jlifE1dmM6430y5eJnWVIf442dQgEDREYcsHx9aJPo(nnwoXavxplJ4G2ah)wKxMJ6GvkfQUEwgXbTbo(n6khbmcdVUvpzbPWREGXuh)MglNyMJ1a2a7VsDqKxMd3QdwP0g89DaBG9xPo4GkDLJagr0OC3mLMp8ydS)k1bu3Qx7z41T6jlifE1dmM6430y5eJnWVIbUxGwx9I8YCGndayQJFtHuBGFfdCVaTU6HIqm86w9KfKcV6bgtD8BASCIbCVaTU6XqKa1WRB1twqk8Qhym1XVPXYjMmW)JbdK2Wr(LTV6XjKiT8BbJPo(nfYjKiVmh8Y4bdCeWm86w9KfKcV6bgtD8BASCIjd8)yWaPnCKFz7RECcjYlZ5lBV)kLsCq1l7qbFA41T6jlifE1dmM6430y5etglHkdgiTHJ8lBF1JtigEDREYcsHx9aJPo(nnwoXKXsOYGbsB4iVmh1bRu6zxUJ5NUYraJanspNPND5oMFAVbnspNPND5oMFkEF)kyCWP6vpifQUnmdPNZdZxplbFH0Zz6zxUJ5Ncv3gwq2Ey4jlbpTY1wdHROEiOCbjQCCD1dki5B(nsSoctc1mj3QNSmjWbvi1WRG07AGelijVFh46jluwWEwfKGdQqrecs4vpWyQJFtfri4jerecYvocyeIqfKw8PdFUGSftcPNZuOkX)WBndtX77xbnP4mj4u9QhKcv3gMH0Z5Hnj(YKEwctIVmjKEotHQe)dV1mmfQUnSjfVG0T6jlbj4EbAD1JHibQqf80Qicb5khbmcrOcsl(0HpxqQoyLsp7YDm)0vocyeMeAtcPNZ0ZUChZpT3ysOnjKEotp7YDm)u8((vqtkotcovV6bPq1THzi9CEytIVmPNLWK4ltcPNZ0ZUChZpfQUnSG0T6jlbzglHkdgiTHfQGhuseHGCLJagHiubPB1twcYmW)JbdK2Wcsl(0Hpxq2IjXTjPNn8vptkAutIqQ0mW)JbdK2Wu8((vqtkooM0ZsysrJAsQdwPuhAxr4LD0vocyeMeAtIqQ0mW)JbdK2Wu8((vqtkotQftYkLacjQkQdTRi8YokEF)kOjfRjH0ZzQdTRi8Yokrh76jltkEtcTjzLsaHevf1H2veEzhfVVFf0KIZKqDtkEtcTj1IjH0ZzkWB7myh)gT3ysrJAsCBsi9CMIaKscqhQ0EJjfVG0YVfmM643uOGNqeQGhuxeHGCLJagHiubPB1twcYmW)JbdK2Wcsl(0HpxqI0ZzAd((smX5agQ82J2Bmj0MeEz8Gbocycsl)wWyQJFtHcEcrOcEqnrecYvocyeIqfKw8PdFUGuDWkL6q7kcVSJUYraJWKqBsTys69NjHcoMeFYvtkAutcPNZueGusa6qL2BmP4nj0MulMKvkbesuvuG32ziDmuP499RGMekmjUAsXBsOnPwmjUnj1bRu6zxUJ5NUYraJWKIg1K42Kq65m9Sl3X8t7nMeAtIBtYkLacjQk6zxUJ5N2BmP4fKUvpzjiDODfHx2jubp8Picb5khbmcrOcsl(0HpxqI0ZzkWB7myh)gT3ysOnPwmjCVwwIFJIQRiGnZdpmKb82odpyh)wzhDCPFnnJWKIg1K42Kq65m97qDyMmZ0GXgy)vkK2Bmj0MK6Gvk97qDyMmZ0GXgy)vkKUYraJWKIxq6w9KLGe4TDgshdvHk4HpiIqqUYraJqeQG0IpD4ZfKQdwP0b2FL6agcWHkDLJagHjH2KAXK((aqfl)MuCMeFGRMu8cs3QNSeKdS)k1bmeGdvHk4HpkIqqUYraJqeQG0IpD4ZfKQdwPuOkX)WBndtx5iGrysOnPwmjSFeS1ELsDcci1k7LAsXzsOKjfnQjH9JGT2RuQtqaPxzsOWKqnUAsXBsOnPwmPVpauXYVjfNjH6OUjfVG0T6jlbjuL4F4TMHfQGhuUicb5khbmcrOcsl(0HpxqQoyLsNnqE1JbdK2W0vocyeMeAtYkLacjQkkWB7mKogQu8((vqtkooM0ZsiiDREYsqoBG8QhdgiTHfQGNq4Qicb5khbmcrOcsl(0HpxqQoyLsNnqE1JbdK2W0vocyeMeAtcPNZ0zdKx9yWaPnmT3iiDREYsqc82odPJHQqf8esiIieKRCeWieHkiT4th(CbP6GvkfCCPFeSV)(otL6(0vocyecs3QNSeKGJl9JG9933zQu3xOcEcPvrecYvocyeIqfKw8PdFUGePNZ0zdKdYKz2dpxzWErm8vpAVXKqBsQdwP0Vd1HzYmtdgBG9xPq6khbmctcTjH0Zz63H6WmzMPbJnW(RuiT3iiDREYsqohRbCP7HNqf8eckjIqqUYraJqeQG0IpD4ZfKi9CMcvj(hERzyAVXKqBsi9CM(DOomtMzAWydS)kfs7nMeAt67davS8BsXzs8jxfKUvpzjib3lqRREmejqfQGNqqDrecYvocyeIqfKw8PdFUGePNZ0zdKdYKz2dpxzWErm8vpAVXKqBsTysQdwP0Vd1HzYmtdgBG9xPq6khbmctcTj1IjH0Zz63H6WmzMPbJnW(RuiT3ysrJAswPeqirvrbEBNH0XqLI33VcAsOWK4QjH2K((aqfl)Mek4ysO8wnPOrnjyZaaM643ui1g4xXa3lqRREMuCMuRMeAtcPNZuOkX)WBndt7nMeAtYkLacjQkkWB7mKogQu8((vqtkooM0ZsysXBsrJAsCBsQdwP0Vd1HzYmtdgBG9xPq6khbmctkAutYkLacjQk6a7VsDadb4qLI33VcAsXXXKGt1REqkuDBygspNh2K4lt6zjmj(YKA1KIxq6w9KLGCowd4s3dpHk4jeuteHGCLJagHiubPfF6WNliHndayQJFtHuBGFfdCVaTU6zsOWKcXKqBsCBsesLMb(FmyG0gMIxgpyGJaMjH2K42KW9Azj(n6SbYbzYm7HNRmyVig(QhDCPFnnJWKqBsTysCBsQdwP0Vd1HzYmtdgBG9xPq6khbmctkAutcPNZ0Vd1HzYmtdgBG9xPqAVXKIg1KSsjGqIQIc82odPJHkfVVFf0KqHjXvtcTj99bGkw(njuWXKq5TAsXliDREYsqohRbCP7HNqf8ecFkIqqUYraJqeQG0IpD4ZfKwPeqirvXWZTQjH2KAXK42Kq65m97qDyMmZ0GXgy)vkK2Bmj0MespNPND5oMFAVXKIxq6w9KLGe4TDgshdvHk4je(Gicb5khbmcrOcsl(0HpxqALsaHevfdp3QMeAtYg443GMekmj1bRu6SbsMmZ0GXgy)vkKUYraJWKqBsCBsi9CME2L7y(P9gbPB1twcsG32ziDmufQGNq4JIieKRCeWieHkiT4th(CbP6GvkD2ajtMzAWydS)kfsx5iGrysOnjUnjKEot)ouhMjZmnySb2FLcP9gtcTj99bGkw(njuWXKqnUAsOnjUnjKEotNnqoitMzp8CLb7fXWx9O9gbPB1twcsG32ziDmufQGNqq5IieKRCeWieHkiT4th(CbzlMeUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzeMu0OMeSzaatD8BkKAd8RyG7fO1vptkotQvtkEtcTj1IjPoyLs)ouhMjZmnySb2FLcPRCeWimj0Me3MespNPZgihKjZShEUYG9Iy4RE0EJjH2KAXKq65m97qDyMmZ0GXgy)vkK2BmPOrnPVpauXYVjHcoMekVvtkAutc2maGPo(nfsTb(vmW9c06QNjfNj1QjH2Kq65mfQs8p8wZW0EJjH2KSsjGqIQIc82odPJHkfVVFf0KIJJj9SeMu8Mu0OMe3MK6Gvk97qDyMmZ0GXgy)vkKUYraJWKIg1KSsjGqIQIoW(RuhWqaouP499RGMuCCmj4u9QhKcv3gMH0Z5Hnj(YKEwctIVmPwnP4fKUvpzjiNJ1agmqAdlubpTYvrecYvocyeIqfKw8PdFUGuDWkLE2L7y(PRCeWimj0MK6Gvk97qDyMmZ0GXgy)vkKUYraJWKqBsi9CME2L7y(P9gtcTjH0Zz63H6WmzMPbJnW(RuiT3iiDREYsqMXsOYGbsByHk4P1qeriix5iGricvqAXNo85csKEotDODfHx2r7ncs3QNSeKaVTZq6yOkubpT2Qicb5khbmcrOcsl(0HpxqALsaHevfdp3QMeAtIBtsDWkL(DOomtMzAWydS)kfsx5iGriiDREYsqc82odPJHQqf80kkjIqqUYraJqeQG0IpD4ZfKQdwP0ZUChZpDLJagHjH2K42KAXK((aqfl)Mekmjuc1mj0MKvkbesuvuG32ziDmuP499RGMuCCmjUAsXliDREYsqE2L7y(fQGNwrDrecYvocyeIqfKw8PdFUGuDWkLE2L7y(PRCeWimj0MespNPND5oMFAVXKqBsTysi9CME2L7y(P499RGMuCM0Zsys8LjH6MeFzsi9CME2L7y(Pq1THnPOrnjKEotHQe)dV1mmT3ysrJAsCBsQdwP0Vd1HzYmtdgBG9xPq6khbmctkEbPB1twcYmwcvgmqAdlubpTIAIieKUvpzjibEBNH0XqvqUYraJqeQqf80kFkIqqUYraJqeQG0T6jlbzg4)XGbsBybPfF6WNliXlJhmWratqA53cgtD8BkuWticvWtR8brecYvocyeIqfKw8PdFUGe3RLL43OdS)k1bSXL(boe81)0XL(10mctcTjXTjH0Zz6a7VsDaBCPFGdbF9pJyi9CM2Bmj0Me3MK6GvkDG9xPoGHaCOsx5iGrysOnjUnj1bRu6SbYREmyG0gMUYraJqq6w9KLGmJLqLbdK2WcvWtR8rrecs3QNSeK2a)kwGJBpOkix5iGricvOcEAfLlIqqUYraJqeQG0IpD4ZfKQdwPuO66zzeh0g443ORCeWieKUvpzjiHQRNLrCqBGJFtOcEqjUkIqqUYraJqeQG0IpD4ZfKCBsQdwP0g89DaBG9xPo4GkDLJagHjfnQjXTj1mLMp8ydS)k1bu3Qx7jiDREYsqohRbSb2FL6aHk4bLcreHGCLJagHiubPfF6WNliHndayQJFtHuBGFfdCVaTU6zsOWKcrq6w9KLG0g4xXa3lqRREcvWdk1QicbPB1twcsW9c06Qhdrcub5khbmcrOcvWdkHsIieKFz7REcEcrqUYraJ9LTV6jcvq6w9KLGmd8)yWaPnSG0YVfmM643uOGNqeKw8PdFUGeVmEWahbmb5khbmcrOcvWdkH6IieKRCeWieHkix5iGX(Y2x9eHkiT4th(Cb5x2E)vkL4GQx2zsOWK4tbPB1twcYmW)JbdK2WcYVS9vpbpHiubpOeQjIqq(LTV6j4jeb5khbm2x2(QNiubPB1twcYmwcvgmqAdlix5iGricvOcEqj(ueHGCLJagHiubPfF6WNlivhSsPND5oMF6khbmctcTjH0Zz6zxUJ5N2Bmj0MespNPND5oMFkEF)kOjfNjbNQx9GuO62WmKEopSjXxM0Zsys8LjH0Zz6zxUJ5Ncv3gwq6w9KLGmJLqLbdK2WcvOcsIL9oqfri4jerecYvocyeIqfKedAXxJEYsqY3u6W4EJAsYSjzDOcPcs3QNSeKO6kcgmyowOcEAveHG8lBF1tWticYvocySVS9vprOcs3QNSeKWMdFkQCq4HHSh2TtqUYraJqeQqf8GsIieKUvpzjiBK6jlb5khbmcrOcvWdQlIqq6w9KLGSdh709HcYvocyeIqfQGhuteHGCLJagHiubPfF6WNliBXK42KuhSsPdS)k1bmeGdv6khbmctkEtcTjXTjPNn8vptcTjXTj1mLcvj(Zgy)vQdOUvV2ZKqBsTysWMbam1XVPqQnWVIbUxGwx9mP4mjuYKIg1KuhSsPFhQdZKzMgm2a7VsH0vocyeMu0OMeUxllXVrHH5hbpp8Wqw(gMFgX(hC0XL(10mctkEbPB1twcYmW)JbdK2WcvWdFkIqqUYraJqeQG0T6jlbzd((smX5agQ82tqAXNo85csUnjKEotBW3xIjohWqL3E0EJjH2KAXK42KAMsHQe)zdS)k1bu3Qx7zsrJAsWMbam1XVPqQnWVIbUxGwx9mP4mjuYKqBsi9CMIQRiyVouPq1THnP4mPw5QjfnQjbLDaYveuWCcgc)SX37)gWORCeWimP4nj0MulMeSzaatD8BkKAd8RyG7fO1vptkotc1mPOrnj1bRu63H6WmzMPbJnW(RuiDLJagHjfnQjH71Ys8Buyy(rWZdpmKLVH5NrS)bhDCPFnnJWKIg1KGYoa5kckyobdHF2479Fdy0vocyeMu8csl)wWyQJFtHcEcrOcE4dIieKRCeWieHkiT4th(Cbj3MKE2Wx9mj0MulMe3MuZukuL4pBG9xPoG6w9AptkAutc2maGPo(nfsTb(vmW9c06QNjfNjHsMeAtcPNZuuDfb71HkfQUnSjfNj1kxnP4nj0MulMeSzaatD8BkKAd8RyG7fO1vptkotcLmPOrnj1bRu63H6WmzMPbJnW(RuiDLJagHjfnQjH71Ys8Buyy(rWZdpmKLVH5NrS)bhDCPFnnJWKIxq6w9KLGmd8)yWaPnSqf8WhfriiDREYsqMp8ydS)k1bcYvocyeIqfQGhuUicbPB1twcY)0jXcYvocyeIqfQGNq4Qicb5khbmcrOcsl(0HpxqYTjPoyLsDODfHx2rx5iGrysrJAsi9CM6q7kcVSJ2BmPOrnjRuciKOQOo0UIWl7O499RGMekmjuJRcs3QNSeKiaPKGL7y(fQGNqcreHGCLJagHiubPfF6WNli52KuhSsPo0UIWl7ORCeWimPOrnjKEotDODfHx2r7ncs3QNSeKiddho8vpHk4jKwfriix5iGricvqAXNo85csUnj1bRuQdTRi8Yo6khbmctkAutcPNZuhAxr4LD0EJjfnQjzLsaHevf1H2veEzhfVVFf0KqHjHACvq6w9KLGmF4HaKscHk4jeuseHGCLJagHiubPfF6WNli52KuhSsPo0UIWl7ORCeWimPOrnjKEotDODfHx2r7nMu0OMKvkbesuvuhAxr4LDu8((vqtcfMeQXvbPB1twcsVSdQyhWSoaiubpHG6IieKRCeWieHkiT4th(Cbj3MK6Gvk1H2veEzhDLJagHjfnQjXTjH0ZzQdTRi8YoAVrq6w9KLGeXFmzMP4ZggkubpHGAIieKUvpzjiBpyZWmvQ7lix5iGricvOcEcHpfriix5iGricvqAXNo85csRS9kVuADVaLL9zsOnPwmjUnj1bRu63H6WmzMPbJnW(RuiDLJagHjfnQjH0Zz63H6WmzMPbJnW(RuiT3ysXBsOnjyZaaM643ui1g4xXa3lqRREMuCMekjiDREYsqM9XuSxWChEYsOcEcHpiIqqUYraJqeQG0IpD4ZfKUvV2JTA)BqtcfMuRMeAtQftc2maGPo(nfsTb(vmW9c06QNjHctQvtkAutc2maGPo(nfsbEBNHm)BsOWKA1KIxq6w9KLGe3lMB1twmWbvbj4GkR8)eKUCcvWti8rrecYvocyeIqfKw8PdFUGKBtsDWkLcvj(Zgy)vQdORCeWimj0MKB1R9yR2)g0KIJJj1QGeQ4ZQcEcrq6w9KLGe3lMB1twmWbvbj4GkR8)eKWREGXuh)MkubpHGYfriix5iGricvqAXNo85cs1bRukuL4pBG9xPoGUYraJWKqBsUvV2JTA)BqtkooMuRcsOIpRk4jebPB1twcsCVyUvpzXahufKGdQSY)tqchdE1dmM643uHkubzdEw5hXvrecEcreHGCLJagHiubPB1twcY5ynGnW(Ruhiijg0IVg9KLGKVJVF2UoctAThMFtsV)mjnyMKBvj2KoOj5T9d4iGrfKw8PdFUGKBtsDWkL2GVVdydS)k1bhuPRCeWieQGNwfriix5iGricvq6w9KLGeQs8p8wZWcsIbT4RrpzjirzdotIuL4F4TMHnPg8SYpIRMuVadcnjO8ptYjiGMeQoaWKGnoQktckLfvqAXNo85cs1bRukuL4F4TMHPRCeWimj0MulMe2pc2AVsPobbKAL9snP4mjuYKIg1KW(rWw7vk1jiG0RmjuysOgxnP4fQGhuseHG0T6jlbz(WJnW(Ruhiix5iGricvOcEqDrecYvocyeIqfKw8PdFUGuDWkLoW(RuhWqaouPRCeWimj0MeSzaatD8BkKAd8RyG7fO1vptkotcLeKUvpzjihy)vQdyiahQcvWdQjIqqUYraJqeQG0IpD4ZfKCBsQdwP0b2FL6agcWHkDLJagHjH2KGndayQJFtHuBGFfdCVaTU6zsXzsOKjfnQjH0ZzkuL4F4TMHP9gbPB1twcsG32ziDmufQGh(ueHGCLJagHiubPfF6WNli52KuhSsPdS)k1bmeGdv6khbmctcTjbBgaWuh)McP2a)kg4EbAD1ZKqbhtcLmj0Me3MespNPqvI)H3AgM2BeKUvpzjiTb(vmW9c06QNqf8WheriiDREYsq2i1twcYvocyeIqfQqfKUCIie8eIicbPB1twcsOkXF2a7VsDGGCLJagHiuHk4PvrecYvocyeIqfKw8PdFUGePNZuRdamW9c06QhfVVFf0KqbhtkeUkiDREYsqo(htMzAWyqvI)cvWdkjIqqUYraJqeQG0IpD4ZfKi9CMoBG8QhdgiTHP9gbPB1twcY5ynGlDp8eQGhuxeHG0T6jlbPnWVIf442dQcYvocyeIqfQGhuteHGCLJagHiubPfF6WNlivhSsPqvI)H3AgMUYraJqq6w9KLGeQs8p8wZWcvWdFkIqqUYraJqeQG0T6jlbzg4)XGbsBybPfF6WNliXlJhmWraZKqBsTysTysUvV2JrivAg4)XGbsBytkotQvtcTj5w9Ap2Q9VbnP44ysOKjH2KSsjGqIQI2GVVetCoGHkV9O499RGMuCMui8PjH2KSY2R8sP1SyjqIjmj0Me3MuZukuL4pBG9xPoG6w9AptkAutYT61EmcPsZa)pgmqAdBsXzsHysOnj3Qx7XwT)nOjHcoMeQBsOnjUnPMPuOkXF2a7VsDa1T61EMeAtsDWkL(DOomtMzAWydS)kfsx5iGrysXBsrJAsTys4ETSe)gfgMFe88Wddz5By(ze7FWrhx6xtZimj0Me3MuZukuL4pBG9xPoG6w9AptkEtkEbPLFlym1XVPqbpHiubp8brecYvocyeIqfKw8PdFUGKBtYT61EmcPsZa)pgmqAdBsOnjUnPMPuOkXF2a7VsDa1T61EMeAtQftsDWkL(DOomtMzAWydS)kfsx5iGrysrJAs4ETSe)gfgMFe88Wddz5By(ze7FWrhx6xtZimP4fKUvpzjiZa)pgmqAdlubp8rrecYvocyeIqfKw8PdFUGuDWkLoBG8QhdgiTHPRCeWimj0M03haQy53KqbhtIp5QjH2KAXKW9Azj(n6SbYbzYm7HNRmyVig(QhDCPFnnJWKqBsi9CMoBGCqMmZE45kd2lIHV6r7nMu0OMe3MeUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzeMu8cs3QNSeKZgiV6XGbsByHk4bLlIqqUYraJqeQG0IpD4ZfKQdwPuhAxr4LD0vocyeMeAtQftIBtQzkfQs8NnW(RuhqDRETNjfVjH2KAXK42KuhSsPND5oMF6khbmctkAutIBtcPNZ0ZUChZpT3ysOnjUnjRuciKOQOND5oMFAVXKIxq6w9KLG0H2veEzNqf8ecxfriix5iGricvqAXNo85cs1bRuk44s)iyF)9DMk19PRCeWieKUvpzjibhx6hb77VVZuPUVqf8esiIieKRCeWieHkiT4th(CbjSzaatD8BkKAd8RyG7fO1vptkotc1nj0MespNPFhQdZKzMgm2a7VsH0EJjH2K((aqfl)MuCMeQXvbPB1twcsBGFfdCVaTU6jubpH0Qicb5khbmcrOcsl(0HpxqI71Ys8B0zdKdYKz2dpxzWErm8vp64s)AAgHjH2K42Kq65mD2a5GmzM9WZvgSxedF1J2BeKUvpzjiNJ1agmqAdlubpHGsIieKRCeWieHkiT4th(CbjHuPzG)hdgiTHP499RGMeAtc2maGPo(nfsTb(vmW9c06QNjfNjH6MeAtQftIBtQzkfQs8NnW(RuhqDRETNjfVjH2KAXKq65mf4TDgSJFJ2Bmj0Me3MespNPFhQdZKzMgm2a7VsH0EJjH2KuhSsPFhQdZKzMgm2a7VsH0vocyeMu8cs3QNSeKaVTZq6yOkubpHG6IieKRCeWieHkiT4th(CbjSzaatD8BkKAd8RyG7fO1vptcfCmPwnj0Me3MeUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzeMeAtQftsDWkL(DOomtMzAWydS)kfsx5iGrysOnPVpauXYVjHcoMeQXvtcTjXTjH0Zz63H6WmzMPbJnW(RuiT3ysXliDREYsqohRbCP7HNqf8ecQjIqqUYraJqeQG0IpD4ZfKesLMb(FmyG0gMI33VcAsOnjKEotbEBNb743O9gtcTjH0ZzAd((smX5agQ82J2BeKUvpzjibEBNH0XqvOcEcHpfriix5iGricvqAXNo85cscPsZa)pgmqAdtX77xbnj0MeSzaatD8BkKAd8RyG7fO1vptkotc1nj0MeUxllXVrHH5hbpp8Wqw(gMFgX(hC0XL(10mctcTjH0ZzkWB7myh)gT3ysOnj1bRu63H6WmzMPbJnW(RuiDLJagHjH2K42Kq65m97qDyMmZ0GXgy)vkK2Bmj0M03haQy53Kqbhtc14QG0T6jlbjWB7mKogQcvWti8brecYvocyeIqfKw8PdFUGKqQ0mW)JbdK2Wu8((vqtcTj1Ij1IjbBgaWuh)McP2a)kg4EbAD1ZKIZKqDtcTjH71Ys8Buyy(rWZdpmKLVH5NrS)bhDCPFnnJWKqBsQdwP0Vd1HzYmtdgBG9xPq6khbmctkEtkAutQftsDWkL(DOomtMzAWydS)kfsx5iGrysOnPVpauXYVjHcoMeQXvtcTjXTjH0Zz63H6WmzMPbJnW(RuiT3ysOnPwmjUnjCVwwIFJoBGCqMmZE45kd2lIHV6rhx6xtZimPOrnjKEotNnqoitMzp8CLb7fXWx9O9gtkEtcTjXTjH71Ys8Buyy(rWZdpmKLVH5NrS)bhDCPFnnJWKI3KIxq6w9KLGe4TDgshdvHk4je(Oicb5khbmcrOcsl(0HpxqsivAg4)XGbsBykEF)kOjH2KGndayQJFtHuBGFfdCVaTU6zsCmju3KqBs4ETSe)gfgMFe88Wddz5By(ze7FWrhx6xtZimj0MespNPaVTZGD8B0EJjH2KuhSsPFhQdZKzMgm2a7VsH0vocyeMeAtIBtcPNZ0Vd1HzYmtdgBG9xPqAVXKqBsFFaOILFtcfCmjuJRcs3QNSeKaVTZq6yOkubpHGYfriix5iGricvqAXNo85csyZaaM643ui1g4xXa3lqRREMek4ysTkiDREYsqohRbCP7HNqf80kxfriix5iGricvqAXNo85csKEotHQe)dV1mmfVVFf0KIZKqjtIVmPNLWK4ltcPNZuOkX)WBndtHQBdliDREYsqAd8RyG7fO1vpHk4P1qeriix5iGricvqAXNo85csKEotbEBNb743O9gtcTjbBgaWuh)McP2a)kg4EbAD1ZKIZKqDtcTj1IjXTj1mLcvj(Zgy)vQdOUvV2ZKI3KqBsesLMb(FmyG0gMQNn8vpbPB1twcsG32ziDmufQGNwBveHGCLJagHiubPfF6WNlivhSsPdS)k1bmeGdv6khbmctcTjbBgaWuh)McP2a)kg4EbAD1ZKIZKqntcTj1IjXTj1mLcvj(Zgy)vQdOUvV2ZKIxq6w9KLGCG9xPoGHaCOkubpTIsIieKRCeWieHkiT4th(CbP6Gvk1H2veEzhDLJagHG0T6jlbjWB7mK5FHk4PvuxeHG0T6jlbPnWVIbUxGwx9eKRCeWieHkubpTIAIieKRCeWieHkix5iGX(Y2x9eHkiT4th(CbjspNPaVTZGD8B0EJjH2KSsjGqIQIHNBvbPB1twcsG32ziDmufKFz7REcEcrOcEALpfrii)Y2x9e8eIGCLJag7lBF1teQG0T6jlbzg4)XGbsBybPLFlym1XVPqbpHiiT4th(CbjEz8GbocycYvocyeIqfQGNw5dIieKFz7REcEcrqUYraJ9LTV6jcvq6w9KLGmJLqLbdK2WcYvocyeIqfQqfKWXGx9aJPo(nveHGNqeriiDREYsqcvj(Zgy)vQdeKRCeWieHkubpTkIqqUYraJqeQG0IpD4ZfKi9CMADaGbUxGwx9O499RGMek4ysHWvbPB1twcYX)yYmtdgdQs8xOcEqjrecYvocyeIqfKw8PdFUGuDWkLE2L7y(PRCeWimj0MespNPND5oMFAVXKqBsi9CME2L7y(P499RGMuCMeCQE1dsHQBdZq658WMeFzsplHjXxMespNPND5oMFkuDBytcTjH0ZzkQUIG96qLcv3g2KIZKcHpkiDREYsqMXsOYGbsByHk4b1friix5iGricvqAXNo85cs1bRu6a7VsDadb4qLUYraJqq6w9KLGCG9xPoGHaCOkubpOMicb5khbmcrOcsl(0HpxqQoyLsHQe)dV1mmDLJagHG0T6jlbjuL4F4TMHfQGh(ueHGCLJagHiubPfF6WNlivhSsPZgiV6XGbsBy6khbmctcTjzLsaHevff4TDgshdvkEF)kOjfhht6zjmj0MeSzaatD8BkKAd8RyG7fO1vptkotQvtkAut67davS8BsOGJjXNC1KqBsWMbam1XVPqQnWVIbUxGwx9mjuWXKA1KqBsTysCBs4ETSe)gD2a5GmzM9WZvgSxedF1JoU0VMMrysrJAsi9CMoBGCqMmZE45kd2lIHV6r7nMu8Mu0OMeSzaatD8BkKAd8RyG7fO1vptkotQvtcTjH0ZzkQUIG96qLcv3g2Kqbhtke(OjH2KAXK42KW9Azj(n6SbYbzYm7HNRmyVig(QhDCPFnnJWKIg1Kq65mD2a5GmzM9WZvgSxedF1J2BmP4nj0M03haQy53KqbhtIp5QG0T6jlb5SbYREmyG0gwOcE4dIieKRCeWieHkiT4th(CbzlMespNPO6kc2RdvkuDBytkotke(OjH2K42Kq65mfbiLeGouP9gtkEtkAutcPNZuG32zWo(nAVrq6w9KLGe4TDgshdvHk4HpkIqqUYraJqeQG0IpD4ZfKQdwP0zdKx9yWaPnmDLJagHjH2Kq65mD2a5vpgmqAdt7nMeAtc2maGPo(nfsTb(vmW9c06QNjfNj1QG0T6jlbjWB7mKogQcvWdkxeHGCLJagHiubPfF6WNlivhSsPZgiV6XGbsBy6khbmctcTjH0Zz6SbYREmyG0gM2Bmj0MeSzaatD8BkKAd8RyG7fO1vptcfCmPwfKUvpzjiNJ1aU09WtOcEcHRIieKRCeWieHkiT4th(CbjspNPqvI)H3AgM2BeKUvpzjib3lqRREmejqfQGNqcreHGCLJagHiubPfF6WNlir65mD2a5GmzM9WZvgSxedF1J2BeKUvpzjiNJ1aU09WtOcEcPvrecYvocyeIqfKw8PdFUGe2maGPo(nfsTb(vmW9c06QNjfNj1QjH2K((aqfl)Mek4ys8jxnj0MulMespNPO6kc2RdvkuDBytkotQvUAsrJAsFFaOILFtcfMekNRMu8Mu0OMulMeUxllXVrNnqoitMzp8CLb7fXWx9OJl9RPzeMeAtIBtcPNZ0zdKdYKz2dpxzWErm8vpAVXKIxq6w9KLGCowdyWaPnSqf8eckjIqqUYraJqeQG0IpD4ZfKTysWMbam1XVPqQnWVIbUxGwx9mjuysHysXBsOnPwmjUnjcPsZa)pgmqAdtXlJhmWraZKIxq6w9KLGCowd4s3dpHk4jeuxeHGCLJagHiubPfF6WNliDREThB1(3GMekmPqmj0MuZukuL4pBG9xPoG6w9AptcTjH0ZzkcqkjaDOs7ncs3QNSeK2a)kg4EbAD1tOcEcb1eriix5iGricvqAXNo85cYMPuOkXF2a7VsDa1T61EMeAtcPNZueGusa6qL2BeKUvpzjib3lqRREmejqfQGNq4trecYvocyeIqfKw8PdFUGePNZuhAxr4LD0EJG0T6jlbjWB7mKogQcvWti8brecYvocyeIqfKw8PdFUG0kLacjQkgEUvfKUvpzjibEBNH0XqvOcEcHpkIqqUYraJqeQG0IpD4ZfKwPeqirvXWZTQjH2KSbo(nOjHctsDWkLoBGKjZmnySb2FLcPRCeWieKUvpzjibEBNH0XqvOcEcbLlIqqUYraJqeQG0IpD4ZfKQdwP0ZUChZpDLJagHjH2Kq65m9Sl3X8t7ncs3QNSeKzSeQmyG0gwOcEALRIieKUvpzjiTb(vSah3EqvqUYraJqeQqf80AiIieKRCeWieHkiT4th(CbP6GvkfQUEwgXbTbo(n6khbmcbPB1twcsO66zzeh0g443eQGNwBveHGCLJagHiubPfF6WNli52KuhSsPn477a2a7VsDWbv6khbmctkAutsDWkL2GVVdydS)k1bhuPRCeWimj0MulMe3MuZukuL4pBG9xPoG6w9AptkEbPB1twcY5ynGnW(RuhiubpTIsIieKRCeWieHkiT4th(CbPB1R9yR2)g0KqHjfIjH2KAXKGndayQJFtHuBGFfdCVaTU6zsOWKcXKIg1KGndayQJFtHuG32ziZ)MekmPqmP4fKUvpzjiTb(vmW9c06QNqf80kQlIqq6w9KLGeCVaTU6XqKavqUYraJqeQqf80kQjIqq(LTV6j4jeb5khbm2x2(QNiubPB1twcYmW)JbdK2Wcsl)wWyQJFtHcEcrqAXNo85cs8Y4bdCeWeKRCeWieHkubpTYNIieKRCeWieHkix5iGX(Y2x9eHkiT4th(Cb5x2E)vkL4GQx2zsOWK4tbPB1twcYmW)JbdK2WcYVS9vpbpHiubpTYherii)Y2x9e8eIGCLJag7lBF1teQG0T6jlbzglHkdgiTHfKRCeWieHkuHkuHkuHaa]] )

end
