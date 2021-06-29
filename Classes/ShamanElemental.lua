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

    spec:RegisterPack( "Elemental", 20210629, [[diuO8bqiuupcsi2eKAusjoLivRcfPELiPzjcUfKqQDH0VejggkIJjiTmPKEgKGPHskxdskBdfjFdsQACOKkNdsOwhkPQAEIuUhkSpirhesQuwOG4HqsfnriPs6IqcjNeLuLvIszMOKQYnHKkv7eL4Pq1ufHUkKuj2lH)IQbl0HPAXq8yknzOCzLnlQpdy0cCAvETGA2Q62aTBj)MOHlfhhLKLJ45GMoPRlvBxk13HKmEiPcNhLQ5lI2pflcvKOahZ1jyPvM0AOmHPAfftdf1hkkWewNaxzVzc8g3g2bMaVCWjWrr9dCL6VaVXz)LoMirbou2j2jWduTbY6pLuaonOJqTsWuGhy)D9KLL4znf4bAtrGJ0Vxz9kbIahZ1jyPvM0AOmHPAfftdf1hkkWeMsGdBMvWsRmvRc8GddBLarGJnOvGJI6h4k1FtepWb9YWgB9AMyRO4emXwzsRHAyZWgQZaVagK1VHnu0MiRxzLKgjX1zIWP6vaqkuDByospNhXeZsIjY6zxUtypbtexLeWWBnJqnSHI2erDddZerDF6Ket0lmteff7ZeLztudMjIRscOj6a(vubEdrMVFcCueuetef1pWvQ)MiEGd6LHnueuetKTEntSvuCcMyRmP1qnSzydfbfXerDg4fWGS(nSHIGIyIOOnrwVYkjnsIRZeHt1RaGuO62WCKEopIjMLetK1ZUCNWEcMiUkjGH3AgHAydfbfXerrBIOUHHzIOUpDsIj6fMjIII9zIYSjQbZeXvjb0eDa)kQHndBOiMikkuhZ21HzIR9iSBI6botudMj6wvsmXdAIEB)Eh5h1WMB1twqAdzwjiIRmMt0a((bUs9pHlZGz1)vkTHCG(Z3pWvQ)huPRCKFyg2qrmruxGZeXvjbm8wZiMydzwjiIRMyV(bHMiucot0XWGMiQU)nryJJQYeHszrnS5w9KfK2qMvcI4AQmsbQscy4TMrs4Ymu)xPuOkjGH3AgHUYr(HHUfIFy81ELsDmmi1k7LMgkKmjXpm(AVsPoggKEfkrnMKUHn3QNSG0gYSsqextLrk5Jm((bUs93WMB1twqAdzwjiIRPYiL9dCL6ph5DOMWLzO(VsP7h4k1FoY7qLUYr(HHg2S)5QtaMcP2a)k(FabADfqAOGHnuetmKz9oCMiRV2HyIbo0eDtujE79MOEGlbtudMj6yyYYeBE3oOjY0AWbnXvkHDM2eLLjI6e1vtmljMikyIWzLfg0evPj6TLhMjIj7i)qrZ6RDiMOSmXM()udBUvpzbPnKzLGiUMkJuEVTZr6eOMWF14wmgOqcxMbZQ)Ru6(bUs9NJ8ouPRCKFyOHn7FU6eGPqQnWVI)hqGwxbKgkKmjspNPqvsadV1mcT3yyZT6jliTHmReeX1uzKInWVI)hqGwxbKWLzWS6)kLUFGRu)5iVdv6kh5hgAyZ(NRobykKAd8R4)beO1vaOKbkGMzKEotHQKagERzeAVXWMB1twqAdzwjiIRPYiLgPEYYWMHnuetK1R0ri9g1eLzt06qfsnS5w9KfmvgPGQRW4WG5edBUvpzbtLrkWMJCkQ8p8iqoaXTlbqz7RayeQHn3QNSGPYiLgPEYYWMB1twWuzKsho(PdeAyZT6jlyQmsj)o44WaPnCcxMrlmR(VsP7h4k1FoY7qLUYr(HLoAM1Zg(ka0m3mLcvjbKVFGRu)PUvV2dDlWM9pxDcWui1g4xX)diqRRasdfsMu9FLsbDOocxM5AW47h4kfsx5i)WsMK0RLLeGrHHzhHmp8iqE(gHDo2ap4OJv9RPzyPByZT6jlyQmsPHCGsc25phvE7LGLD7pU6eGPqgHMWLzWmspNPnKdusWo)5OYBpAVbDlm3mLcvjbKVFGRu)PUvV2lzsyZ(NRobykKAd8R4)beO1vaPHcOr65mfvxHXb6qLcv3goTwzsYKqz)rUcJ(ZX4iSZhQdhS5hDLJ8dlD0TaB2)C1jatHuBGFf)pGaTUcinulzs1)vkf0H6iCzMRbJVFGRuiDLJ8dlzssVwwsagfgMDeY8WJa55Be25yd8GJow1VMMHLmju2FKRWO)Cmoc78H6WbB(rx5i)Ws3WMB1twWuzKs(DWXHbsB4eUmdM1Zg(ka0TWCZukuLeq((bUs9N6w9AVKjHn7FU6eGPqQnWVI)hqGwxbKgkGgPNZuuDfghOdvkuDB40ALjPJUfyZ(NRobykKAd8R4)beO1vaPHcjtQ(VsPGouhHlZCny89dCLcPRCKFyjts61YscWOWWSJqMhEeipFJWohBGhC0XQ(10mS0nS5w9KfmvgPKpY47h4k1FdBUvpzbtLrkGtNKyyZT6jlyQmsb5LsmEUtypHlZGz1)vk1H2vyEzhDLJ8dlzsKEotDODfMx2r7njtALYhtIQI6q7kmVSJsgOFfeLOgtmS5w9KfmvgPGmcCKWxbKWLzWS6)kL6q7kmVSJUYr(HLmjspNPo0UcZl7O9gdBUvpzbtLrk5JmKxkXs4Ymyw9FLsDODfMx2rx5i)WsMePNZuhAxH5LD0EtYKwP8XKOQOo0UcZl7OKb6xbrjQXedBUvpzbtLrkEzhuj(ZT()jCzgmR(VsPo0UcZl7ORCKFyjtI0ZzQdTRW8YoAVjzsRu(ysuvuhAxH5LDuYa9RGOe1yIHn3QNSGPYifehGlZCLC2WWeUmdMv)xPuhAxH5LD0voYpSKjzgPNZuhAxH5LD0EJHn3QNSGPYiL2d2mcxL6anS5w9KfmvgPK9XvIxWChEYkHlZWkBVYlLwhqGYZ(q3cZQ)RukOd1r4YmxdgF)axPq6kh5hwYKi9CMc6qDeUmZ1GX3pWvkK2BshnSz)ZvNamfsTb(v8)ac06kG0qbdBUvpzbtLrkKEXDREYI)hutOCWXWLlHlZWT61E8vd8geLTIUfyZ(NRobykKAd8R4)beO1vaOS1KjHn7FU6eGPq67TDoYCqu2A6g2CREYcMkJui9I7w9Kf)pOMq5GJb8kGFC1jattaQKZQmcnHlZGz1)vkfQsciF)axP(tx5i)Wq7w9Ap(QbEdMgJwnS5w9KfmvgPq6f3T6jl(FqnHYbhd44WRa(XvNamnbOsoRYi0eUmd1)vkfQsciF)axP(tx5i)Wq7w9Ap(QbEdMgJwnSzyZT6jli1LJbuLeq((bUs93WMB1twqQlxQmszSpUmZ1GXHQKaMWLzG0ZzQ1)N)hqGwxbqjd0VcIsgHYedBUvpzbPUCPYiL5enGvDp8s4Ymq65mD2a5vaCyG0gM2BmS5w9KfK6YLkJuSb(v8aN0Eq1WMB1twqQlxQmsbQscy4TMrs4Ymu)xPuOkjGH3AgHUYr(HzyZT6jli1LlvgPKFhCCyG0gobl72FC1jatHmcnHlZGSmzWah5h6wAXT61ECmPsZVdoomqAdNwRODREThF1aVbtJbkG2kLpMevfTHCGsc25phvE7rjd0VcMwOmfARS9kVuAnlr(scgAMBMsHQKaY3pWvQ)u3Qx7LmPB1R94ysLMFhCCyG0goTqr7w9Ap(QbEdIsgSgAMBMsHQKaY3pWvQ)u3Qx7Hw9FLsbDOocxM5AW47h4kfsx5i)WspzYwi9Azjbyuyy2riZdpcKNVryNJnWdo6yv)AAggAMBMsHQKaY3pWvQ)u3Qx7LE6g2CREYcsD5sLrk53bhhgiTHt4Ymy2T61ECmPsZVdoomqAdJM5MPuOkjG89dCL6p1T61EOBr9FLsbDOocxM5AW47h4kfsx5i)WsMK0RLLeGrHHzhHmp8iqE(gHDo2ap4OJv9RPzyPByZT6jli1LlvgPmBG8kaomqAdNWLzO(VsPZgiVcGddK2W0voYpm0G(EOsKGOKbtXe0Tq61YscWOZgihKlZCaYCLd7f2ixbqhR6xtZWqJ0Zz6SbYb5YmhGmx5WEHnYva0EtYKmt61YscWOZgihKlZCaYCLd7f2ixbqhR6xtZWs3WMB1twqQlxQmsXH2vyEzxcxMH6)kL6q7kmVSJUYr(HHUfMBMsHQKaY3pWvQ)u3Qx7Lo6wyw9FLsp7YDc70voYpSKjzgPNZ0ZUCNWoT3GMzRu(ysuv0ZUCNWoT3KUHn3QNSGuxUuzKYFSQFyCqha05QuhycxMH6)kL(hR6hgh0baDUk1bsx5i)WmS5w9KfK6YLkJuSb(v8)ac06kGeUmdyZ(NRobykKAd8R4)beO1vaPXAOr65mf0H6iCzMRbJVFGRuiT3Gg03dvIemnuJjg2CREYcsD5sLrkZjAahgiTHt4Ymi9Azjby0zdKdYLzoazUYH9cBKRaOJv9RPzyOzgPNZ0zdKdYLzoazUYH9cBKRaO9gdBUvpzbPUCPYiL3B7CKobQjCzgysLMFhCCyG0gMsgOFfenSz)ZvNamfsTb(v8)ac06kG0yn0TWCZukuLeq((bUs9N6w9AV0r3cspNPV325Woby0EdAMr65mf0H6iCzMRbJVFGRuiT3Gw9FLsbDOocxM5AW47h4kfsx5i)Ws3WMB1twqQlxQmszordyv3dVeUmdyZ(NRobykKAd8R4)beO1vaOKrROzM0RLLeGrNnqoixM5aK5kh2lSrUcGow1VMMHHUf1)vkf0H6iCzMRbJVFGRuiDLJ8ddnOVhQejikzGAmbnZi9CMc6qDeUmZ1GX3pWvkK2Bs3WMB1twqQlxQms592ohPtGAcxMbMuP53bhhgiTHPKb6xbrJ0Zz67TDoStagT3GgPNZ0gYbkjyN)Cu5ThT3yyZT6jli1LlvgP8EBNJ0jqnHlZatQ087GJddK2WuYa9RGOHn7FU6eGPqQnWVI)hqGwxbKgRHM0RLLeGrHHzhHmp8iqE(gHDo2ap4OJv9RPzyOr65m992oh2jaJ2BqR(VsPGouhHlZCny89dCLcPRCKFyOzgPNZuqhQJWLzUgm((bUsH0EdAqFpujsquYa1yIHn3QNSGuxUuzKY7TDosNa1eUmdmPsZVdoomqAdtjd0VcIULwGn7FU6eGPqQnWVI)hqGwxbKgRHM0RLLeGrHHzhHmp8iqE(gHDo2ap4OJv9RPzyOv)xPuqhQJWLzUgm((bUsH0voYpS0tMSf1)vkf0H6iCzMRbJVFGRuiDLJ8ddnOVhQejikzGAmbnZi9CMc6qDeUmZ1GX3pWvkK2Bq3cZKETSKam6SbYb5YmhGmx5WEHnYva0XQ(10mSKjr65mD2a5GCzMdqMRCyVWg5kaAVjD0mt61YscWOWWSJqMhEeipFJWohBGhC0XQ(10mS0t3WMB1twqQlxQms592ohPtGAcxMbMuP53bhhgiTHPKb6xbrdB2)C1jatHuBGFf)pGaTUcGbRHM0RLLeGrHHzhHmp8iqE(gHDo2ap4OJv9RPzyOr65m992oh2jaJ2BqR(VsPGouhHlZCny89dCLcPRCKFyOzgPNZuqhQJWLzUgm((bUsH0EdAqFpujsquYa1yIHn3QNSGuxUuzKYCIgWQUhEjCzgWM9pxDcWui1g4xX)diqRRaqjJwnS5w9KfK6YLkJuSb(v8)ac06kGeUmdKEotHQKagERzekzG(vW0qbMgWIX0i9CMcvjbm8wZiuO62Wg2CREYcsD5sLrkV325iDcut4Ymq65m992oh2jaJ2BqdB2)C1jatHuBGFf)pGaTUcinwdDlm3mLcvjbKVFGRu)PUvV2lD0ysLMFhCCyG0gMQNn8vag2CREYcsD5sLrk7h4k1FoY7qnHlZq9FLs3pWvQ)CK3HkDLJ8ddnSz)ZvNamfsTb(v8)ac06kG0qn0TWCZukuLeq((bUs9N6w9AV0nS5w9KfK6YLkJuEVTZrMdMWLzO(VsPo0UcZl7ORCKFyg2CREYcsD5sLrk2a)k(FabADfGHn3QNSGuxUuzKY7TDosNa1eaLTVcGrOjCzgi9CM(EBNd7eGr7nOTs5JjrvXjZTQHn3QNSGuxUuzKs(DWXHbsB4eaLTVcGrOjyz3(JRobykKrOjCzgKLjdg4i)mS5w9KfK6YLkJuYeju5WaPnCcGY2xbWiudBg2CREYcsHJdVc4hxDcWugqvsa57h4k1FdBUvpzbPWXHxb8JRobyAQmszSpUmZ1GXHQKaMWLzG0ZzQ1)N)hqGwxbqjd0VcIsgHYedBUvpzbPWXHxb8JRobyAQmsjtKqLddK2WjCzgQ)Ru6zxUtyNUYr(HHgPNZ0ZUCNWoT3GgPNZ0ZUCNWoLmq)kyAWP6vaqkuDByospNhHPbSymnspNPND5oHDkuDBy0i9CMIQRW4aDOsHQBdNwOSodBUvpzbPWXHxb8JRobyAQmsz)axP(ZrEhQjCzgQ)Ru6(bUs9NJ8ouPRCKFyg2CREYcsHJdVc4hxDcW0uzKcuLeWWBnJKWLzO(VsPqvsadV1mcDLJ8dZWMB1twqkCC4va)4QtaMMkJuMnqEfahgiTHt4Ymu)xP0zdKxbWHbsBy6kh5hgARu(ysuv03B7CKobQuYa9RGPXaWIHg2S)5QtaMcP2a)k(FabADfqATMmjOVhQejikzWumbnSz)ZvNamfsTb(v8)ac06kauYOv0TWmPxlljaJoBGCqUmZbiZvoSxyJCfaDSQFnndlzsKEotNnqoixM5aK5kh2lSrUcG2BspzsyZ(NRobykKAd8R4)beO1vaP1kAKEotr1vyCGouPq1THrjJqzDOBHzsVwwsagD2a5GCzMdqMRCyVWg5ka6yv)AAgwYKi9CMoBGCqUmZbiZvoSxyJCfaT3KoAqFpujsquYGPyIHn3QNSGu44WRa(XvNamnvgP8EBNJ0jqnHlZOfKEotr1vyCGouPq1THtluwhAMr65mf5LsSVdvAVj9Kjr65m992oh2jaJ2BmS5w9KfKchhEfWpU6eGPPYiL3B7CKobQjCzgQ)Ru6SbYRa4WaPnmDLJ8ddnspNPZgiVcGddK2W0EdAyZ(NRobykKAd8R4)beO1vaP1QHn3QNSGu44WRa(XvNamnvgPmNObSQ7HxcxMH6)kLoBG8kaomqAdtx5i)WqJ0Zz6SbYRa4WaPnmT3Gg2S)5QtaMcP2a)k(FabADfakz0QHn3QNSGu44WRa(XvNamnvgP8hqGwxbWrKVMWLzG0ZzkuLeWWBnJq7ng2CREYcsHJdVc4hxDcW0uzKYCIgWQUhEjCzgi9CMoBGCqUmZbiZvoSxyJCfaT3yyZT6jlifoo8kGFC1jattLrkZjAahgiTHt4YmGn7FU6eGPqQnWVI)hqGwxbKwROb99qLibrjdMIjOBbPNZuuDfghOdvkuDB40ALjjtc67HkrcIsumtspzYwi9Azjby0zdKdYLzoazUYH9cBKRaOJv9RPzyOzgPNZ0zdKdYLzoazUYH9cBKRaO9M0nS5w9KfKchhEfWpU6eGPPYiL5enGvDp8s4YmAb2S)5QtaMcP2a)k(FabADfakdnD0TWmMuP53bhhgiTHPKLjdg4i)s3WMB1twqkCC4va)4QtaMMkJuSb(v8)ac06kGeUmd3Qx7XxnWBqugk6MPuOkjG89dCL6p1T61EOr65mf5LsSVdvAVXWMB1twqkCC4va)4QtaMMkJu(diqRRa4iYxt4YmAMsHQKaY3pWvQ)u3Qx7HgPNZuKxkX(ouP9gdBUvpzbPWXHxb8JRobyAQms592ohPtGAcxMbspNPo0UcZl7O9gdBUvpzbPWXHxb8JRobyAQms592ohPtGAcxMHvkFmjQkozUvnS5w9KfKchhEfWpU6eGPPYiL3B7CKobQjCzgwP8XKOQ4K5wfTnWjadIs1)vkD2ajxM5AW47h4kfsx5i)WmS5w9KfKchhEfWpU6eGPPYiLmrcvomqAdNWLzO(VsPND5oHD6kh5hgAKEotp7YDc70EJHn3QNSGu44WRa(XvNamnvgPyd8R4boP9GQHn3QNSGu44WRa(XvNamnvgPavxplh7G2aNaSeUmd1)vkfQUEwo2bTboby0voYpmdBUvpzbPWXHxb8JRobyAQmszord47h4k1)eUmdMv)xP0gYb6pF)axP(FqLUYr(HLmP6)kL2qoq)57h4k1)dQ0voYpm0TWCZukuLeq((bUs9N6w9AV0nS5w9KfKchhEfWpU6eGPPYifBGFf)pGaTUciHlZWT61E8vd8geLHIUfyZ(NRobykKAd8R4)beO1vaOm0KjHn7FU6eGPq67TDoYCqugA6g2CREYcsHJdVc4hxDcW0uzKYFabADfahr(QHn3QNSGu44WRa(XvNamnvgPKFhCCyG0gobqz7RayeAcw2T)4QtaMczeAcxMbzzYGboYpdBUvpzbPWXHxb8JRobyAQmsj)o44WaPnCcGY2xbWi0eUmdqz7bUsPyhu9YouYug2CREYcsHJdVc4hxDcW0uzKsMiHkhgiTHtau2(kagHAyZWMB1twqk8kGFC1jatz8hqGwxbWrKVMWLz0cspNPqvsadV1mcLmq)kyAWP6vaqkuDByospNhHPbSymnspNPqvsadV1mcfQUnC6g2CREYcsHxb8JRobyAQmsjtKqLddK2WjCzgQ)Ru6zxUtyNUYr(HHgPNZ0ZUCNWoT3GgPNZ0ZUCNWoLmq)kyAWP6vaqkuDByospNhHPbSymnspNPND5oHDkuDBydBUvpzbPWRa(XvNamnvgPKFhCCyG0gobl72FC1jatHmcnHlZOfM1Zg(kGKjXKkn)o44WaPnmLmq)kyAmaSyjtQ(VsPo0UcZl7ORCKFyOXKkn)o44WaPnmLmq)kyATyLYhtIQI6q7kmVSJsgOFfmvKEotDODfMx2rX6expzLoARu(ysuvuhAxH5LDuYa9RGPXAPJUfKEotFVTZHDcWO9MKjzgPNZuKxkX(ouP9M0nS5w9KfKcVc4hxDcW0uzKs(DWXHbsB4eSSB)XvNamfYi0eUmdKEotBihOKGD(ZrL3E0EdAYYKbdCKFg2CREYcsHxb8JRobyAQmsXH2vyEzxcxMH6)kL6q7kmVSJUYr(HHUf9ahkzWumjzsKEotrEPe77qL2BshDlwP8XKOQOV325iDcuPKb6xbrjtshDlmR(VsPND5oHD6kh5hwYKmJ0Zz6zxUtyN2BqZSvkFmjQk6zxUtyN2Bs3WMB1twqk8kGFC1jattLrkV325iDcut4Ymq65m992oh2jaJ2Bq3cPxlljaJIQRWGnZdpcK)EBNtgStawzhDSQFnndlzsMr65mf0H6iCzMRbJVFGRuiT3Gw9FLsbDOocxM5AW47h4kfsx5i)Ws3WMB1twqk8kGFC1jattLrk7h4k1FoY7qnHlZq9FLs3pWvQ)CK3HkDLJ8ddDlG(EOsKGPH6zs6g2CREYcsHxb8JRobyAQmsbQscy4TMrs4Ymu)xPuOkjGH3AgHUYr(HHUfIFy81ELsDmmi1k7LMgkKmjXpm(AVsPoggKEfkrnMKo6wa99qLibtJ1yT0nS5w9KfKcVc4hxDcW0uzKYSbYRa4WaPnCcxMH6)kLoBG8kaomqAdtx5i)WqBLYhtIQI(EBNJ0jqLsgOFfmngawmdBUvpzbPWRa(XvNamnvgP8EBNJ0jqnHlZq9FLsNnqEfahgiTHPRCKFyOr65mD2a5vaCyG0gM2BmS5w9KfKcVc4hxDcW0uzKYFSQFyCqha05QuhycxMH6)kL(hR6hgh0baDUk1bsx5i)WmS5w9KfKcVc4hxDcW0uzKYCIgWQUhEjCzgi9CMoBGCqUmZbiZvoSxyJCfaT3Gw9FLsbDOocxM5AW47h4kfsx5i)WqJ0ZzkOd1r4YmxdgF)axPqAVXWMB1twqk8kGFC1jattLrk)beO1vaCe5RjCzgi9CMcvjbm8wZi0EdAKEotbDOocxM5AW47h4kfs7nOb99qLibtJPyIHn3QNSGu4va)4QtaMMkJuMt0aw19WlHlZaPNZ0zdKdYLzoazUYH9cBKRaO9g0TO(VsPGouhHlZCny89dCLcPRCKFyOBbPNZuqhQJWLzUgm((bUsH0EtYKwP8XKOQOV325iDcuPKb6xbrjtqd67HkrcIsgO4wtMe2S)5QtaMcP2a)k(FabADfqATIgPNZuOkjGH3AgH2BqBLYhtIQI(EBNJ0jqLsgOFfmngawS0tMKz1)vkf0H6iCzMRbJVFGRuiDLJ8dlzsRu(ysuv09dCL6ph5DOsjd0VcMgd4u9kaifQUnmhPNZJW0awmMU10nS5w9KfKcVc4hxDcW0uzKYCIgWQUhEjCzgWM9pxDcWui1g4xX)diqRRaqzOOzgtQ087GJddK2WuYYKbdCKFOzM0RLLeGrNnqoixM5aK5kh2lSrUcGow1VMMHHUfMv)xPuqhQJWLzUgm((bUsH0voYpSKjr65mf0H6iCzMRbJVFGRuiT3KmPvkFmjQk67TDosNavkzG(vquYe0G(EOsKGOKbkU10nS5w9KfKcVc4hxDcW0uzKY7TDosNa1eUmdRu(ysuvCYCRIUfMr65mf0H6iCzMRbJVFGRuiT3GgPNZ0ZUCNWoT3KUHn3QNSGu4va)4QtaMMkJuEVTZr6eOMWLzyLYhtIQItMBv02aNamikv)xP0zdKCzMRbJVFGRuiDLJ8ddnZi9CME2L7e2P9gdBUvpzbPWRa(XvNamnvgP8EBNJ0jqnHlZq9FLsNnqYLzUgm((bUsH0voYpm0mJ0ZzkOd1r4YmxdgF)axPqAVbnOVhQejikzGAmbnZi9CMoBGCqUmZbiZvoSxyJCfaT3yyZT6jlifEfWpU6eGPPYiL5enGddK2WjCzgTq61YscWOZgihKlZCaYCLd7f2ixbqhR6xtZWsMe2S)5QtaMcP2a)k(FabADfqATMo6wu)xPuqhQJWLzUgm((bUsH0voYpm0mJ0Zz6SbYb5YmhGmx5WEHnYva0Ed6wq65mf0H6iCzMRbJVFGRuiT3KmjOVhQejikzGIBnzsyZ(NRobykKAd8R4)beO1vaP1kAKEotHQKagERzeAVbTvkFmjQk67TDosNavkzG(vW0yayXspzsMv)xPuqhQJWLzUgm((bUsH0voYpSKjTs5Jjrvr3pWvQ)CK3HkLmq)kyAmGt1RaGuO62WCKEopctdyXy6wt3WMB1twqk8kGFC1jattLrkzIeQCyG0goHlZq9FLsp7YDc70voYpm0Q)RukOd1r4YmxdgF)axPq6kh5hgAKEotp7YDc70EdAKEotbDOocxM5AW47h4kfs7ng2CREYcsHxb8JRobyAQms592ohPtGAcxMbspNPo0UcZl7O9gdBUvpzbPWRa(XvNamnvgP8EBNJ0jqnHlZWkLpMevfNm3QOzw9FLsbDOocxM5AW47h4kfsx5i)WmS5w9KfKcVc4hxDcW0uzKYzxUtypHlZq9FLsp7YDc70voYpm0m3cOVhQejikrbudTvkFmjQk67TDosNavkzG(vW0yWK0nS5w9KfKcVc4hxDcW0uzKsMiHkhgiTHt4Ymu)xP0ZUCNWoDLJ8ddnspNPND5oHDAVbDli9CME2L7e2PKb6xbtdWIX0SgtJ0Zz6zxUtyNcv3gozsKEotHQKagERzeAVjzsMv)xPuqhQJWLzUgm((bUsH0voYpS0nS5w9KfKcVc4hxDcW0uzKY7TDosNavdBUvpzbPWRa(XvNamnvgPKFhCCyG0gobl72FC1jatHmcnHlZGSmzWah5NHn3QNSGu4va)4QtaMMkJuYeju5WaPnCcxMbPxlljaJUFGRu)5Jv97peY1bPJv9RPzyOzgPNZ09dCL6pFSQF)HqUoihBi9CM2BqZS6)kLUFGRu)5iVdv6kh5hgAMv)xP0zdKxbWHbsBy6kh5hMHn3QNSGu4va)4QtaMMkJuSb(v8aN0Eq1WMB1twqk8kGFC1jattLrkq11ZYXoOnWjalHlZq9FLsHQRNLJDqBGtagDLJ8dZWMB1twqk8kGFC1jattLrkZjAaF)axP(NWLzWS6)kL2qoq)57h4k1)dQ0voYpSKjzUzknFKX3pWvQ)u3Qx7zyZT6jlifEfWpU6eGPPYifBGFf)pGaTUciHlZa2S)5QtaMcP2a)k(FabADfakd1WMB1twqk8kGFC1jattLrk)beO1vaCe5Rg2CREYcsHxb8JRobyAQmsj)o44WaPnCcGY2xbWi0eSSB)XvNamfYi0eUmdYYKbdCKFg2CREYcsHxb8JRobyAQmsj)o44WaPnCcGY2xbWi0eUmdqz7bUsPyhu9YouYug2CREYcsHxb8JRobyAQmsjtKqLddK2WjakBFfaJqnS5w9KfKcVc4hxDcW0uzKsMiHkhgiTHt4Ymu)xP0ZUCNWoDLJ8ddnspNPND5oHDAVbnspNPND5oHDkzG(vW0Gt1RaGuO62WCKEopctdyXyAKEotp7YDc7uO62Wc82JapzjyPvM0AOmHPAf1lWrLtQRaGcCwpWgjrhMjIAMOB1twM4FqfsnSjW9UgijcC8dS)UEYc1jXZQa)pOcfjkWHxb8JRobyQirblHksuGVYr(HjcrGBjNoY5c8wmrKEotHQKagERzekzG(vqtmnteovVcasHQBdZr658iMitBIawmtKPnrKEotHQKagERzekuDBytmDbUB1twc8)ac06kaoI8vHkyPvrIc8voYpmricCl50roxGR(VsPND5oHD6kh5hMjI2er65m9Sl3jSt7nMiAtePNZ0ZUCNWoLmq)kOjMMjcNQxbaPq1TH5i9CEetKPnralMjY0MispNPND5oHDkuDBybUB1twc8mrcvomqAdlublOGirb(kh5hMiebUB1twc887GJddK2WcCl50roxG3IjYSjQNn8vaMyYKMiMuP53bhhgiTHPKb6xbnX0yyIawmtmzstu9FLsDODfMx2rx5i)Wmr0MiMuP53bhhgiTHPKb6xbnX0mXwmrRu(ysuvuhAxH5LDuYa9RGMyQMispNPo0UcZl7OyDIRNSmX0nr0MOvkFmjQkQdTRW8YokzG(vqtmntK1mX0nr0MylMispNPV325Woby0EJjMmPjYSjI0ZzkYlLyFhQ0EJjMUa3YU9hxDcWuOGLqfQGfwtKOaFLJ8dteIa3T6jlbE(DWXHbsBybULC6iNlWr65mTHCGsc25phvE7r7nMiAtKSmzWah5Na3YU9hxDcWuOGLqfQGfutKOaFLJ8dteIa3soDKZf4Q)RuQdTRW8Yo6kh5hMjI2eBXe1dCMikzyImftmXKjnrKEotrEPe77qL2BmX0nr0MylMOvkFmjQk67TDosNavkzG(vqteLMitmX0nr0MylMiZMO6)kLE2L7e2PRCKFyMyYKMiZMispNPND5oHDAVXerBImBIwP8XKOQOND5oHDAVXetxG7w9KLa3H2vyEzNqfSWuIef4RCKFyIqe4wYPJCUahPNZ03B7CyNamAVXerBITyIKETSKamkQUcd2mp8iq(7TDozWobyLD0XQ(10mmtmzstKztePNZuqhQJWLzUgm((bUsH0EJjI2ev)xPuqhQJWLzUgm((bUsH0voYpmtmDbUB1twc83B7CKobQcvWcQxKOaFLJ8dteIa3soDKZf4Q)Ru6(bUs9NJ8ouPRCKFyMiAtSfte03dvIe0etZer9mXetxG7w9KLaF)axP(ZrEhQcvWcRtKOaFLJ8dteIa3soDKZf4Q)RukuLeWWBnJqx5i)Wmr0MylMiXpm(AVsPoggKAL9snX0mruWetM0ej(HXx7vk1XWG0RmruAIOgtmX0nr0MylMiOVhQejOjMMjYASMjMUa3T6jlbouLeWWBnJiublOyrIc8voYpmricCl50roxGR(VsPZgiVcGddK2W0voYpmteTjALYhtIQI(EBNJ0jqLsgOFf0etJHjcyXe4UvpzjWNnqEfahgiTHfQGLqzIirb(kh5hMiebULC6iNlWv)xP0zdKxbWHbsBy6kh5hMjI2er65mD2a5vaCyG0gM2Be4UvpzjWFVTZr6eOkublHgQirb(kh5hMiebULC6iNlWv)xP0)yv)W4GoaOZvPoq6kh5hMa3T6jlb(FSQFyCqha05QuhOqfSeARIef4RCKFyIqe4wYPJCUahPNZ0zdKdYLzoazUYH9cBKRaO9gteTjQ(VsPGouhHlZCny89dCLcPRCKFyMiAtePNZuqhQJWLzUgm((bUsH0EJa3T6jlb(CIgWQUhEcvWsOOGirb(kh5hMiebULC6iNlWr65mfQscy4TMrO9gteTjI0ZzkOd1r4YmxdgF)axPqAVXerBIG(EOsKGMyAMitXebUB1twc8)ac06kaoI8vHkyjuwtKOaFLJ8dteIa3soDKZf4i9CMoBGCqUmZbiZvoSxyJCfaT3yIOnXwmr1)vkf0H6iCzMRbJVFGRuiDLJ8dZerBITyIi9CMc6qDeUmZ1GX3pWvkK2BmXKjnrRu(ysuv03B7CKobQuYa9RGMiknrMyIOnrqFpujsqteLmmruCRMyYKMiSz)ZvNamfsTb(v8)ac06katmntSvteTjI0ZzkuLeWWBnJq7nMiAt0kLpMevf992ohPtGkLmq)kOjMgdteWIzIPBIjtAImBIQ)RukOd1r4YmxdgF)axPq6kh5hMjMmPjALYhtIQIUFGRu)5iVdvkzG(vqtmngMiCQEfaKcv3gMJ0Z5rmrM2ebSyMitBITAIPlWDREYsGpNObSQ7HNqfSekQjsuGVYr(HjcrGBjNoY5cCyZ(NRobykKAd8R4)beO1vaMiknXqnr0MiZMiMuP53bhhgiTHPKLjdg4i)mr0MiZMiPxlljaJoBGCqUmZbiZvoSxyJCfaDSQFnndZerBITyImBIQ)RukOd1r4YmxdgF)axPq6kh5hMjMmPjI0ZzkOd1r4YmxdgF)axPqAVXetM0eTs5JjrvrFVTZr6eOsjd0VcAIO0ezIjI2eb99qLibnruYWerXTAIPlWDREYsGpNObSQ7HNqfSektjsuGVYr(HjcrGBjNoY5cCRu(ysuvCYCRAIOnXwmrMnrKEotbDOocxM5AW47h4kfs7nMiAtePNZ0ZUCNWoT3yIPlWDREYsG)EBNJ0jqvOcwcf1lsuGVYr(HjcrGBjNoY5cCRu(ysuvCYCRAIOnrBGtag0erPjQ(VsPZgi5YmxdgF)axPq6kh5hMjI2ez2er65m9Sl3jSt7ncC3QNSe4V325iDcufQGLqzDIef4RCKFyIqe4wYPJCUax9FLsNnqYLzUgm((bUsH0voYpmteTjYSjI0ZzkOd1r4YmxdgF)axPqAVXerBIG(EOsKGMikzyIOgtmr0MiZMispNPZgihKlZCaYCLd7f2ixbq7ncC3QNSe4V325iDcufQGLqrXIef4RCKFyIqe4wYPJCUaVftK0RLLeGrNnqoixM5aK5kh2lSrUcGow1VMMHzIjtAIWM9pxDcWui1g4xX)diqRRamX0mXwnX0nr0MylMO6)kLc6qDeUmZ1GX3pWvkKUYr(HzIOnrMnrKEotNnqoixM5aK5kh2lSrUcG2Bmr0MylMispNPGouhHlZCny89dCLcP9gtmzste03dvIe0erjdtef3QjMmPjcB2)C1jatHuBGFf)pGaTUcWetZeB1erBIi9CMcvjbm8wZi0EJjI2eTs5JjrvrFVTZr6eOsjd0VcAIPXWebSyMy6MyYKMiZMO6)kLc6qDeUmZ1GX3pWvkKUYr(HzIjtAIwP8XKOQO7h4k1FoY7qLsgOFf0etJHjcNQxbaPq1TH5i9CEetKPnralMjY0MyRMy6cC3QNSe4ZjAahgiTHfQGLwzIirb(kh5hMiebULC6iNlWv)xP0ZUCNWoDLJ8dZerBIQ)RukOd1r4YmxdgF)axPq6kh5hMjI2er65m9Sl3jSt7nMiAtePNZuqhQJWLzUgm((bUsH0EJa3T6jlbEMiHkhgiTHfQGLwdvKOaFLJ8dteIa3soDKZf4i9CM6q7kmVSJ2Be4UvpzjWFVTZr6eOkublT2Qirb(kh5hMiebULC6iNlWTs5JjrvXjZTQjI2ez2ev)xPuqhQJWLzUgm((bUsH0voYpmbUB1twc83B7CKobQcvWsROGirb(kh5hMiebULC6iNlWv)xP0ZUCNWoDLJ8dZerBImBITyIG(EOsKGMiknrua1mr0MOvkFmjQk67TDosNavkzG(vqtmngMitmX0f4UvpzjWp7YDc7cvWsRSMirb(kh5hMiebULC6iNlWv)xP0ZUCNWoDLJ8dZerBIi9CME2L7e2P9gteTj2IjI0Zz6zxUtyNsgOFf0etZebSyMitBISMjY0MispNPND5oHDkuDBytmzstePNZuOkjGH3AgH2BmXKjnrMnr1)vkf0H6iCzMRbJVFGRuiDLJ8dZetxG7w9KLaptKqLddK2WcvWsROMirbUB1twc83B7CKobQc8voYpmricvWsRmLirb(kh5hMiebUB1twc887GJddK2WcCl50roxGtwMmyGJ8tGBz3(JRobykuWsOcvWsROErIc8voYpmricCl50roxGt61YscWO7h4k1F(yv)(dHCDq6yv)AAgMjI2ez2er65mD)axP(ZhR63FiKRdYXgspNP9gteTjYSjQ(VsP7h4k1FoY7qLUYr(HzIOnrMnr1)vkD2a5vaCyG0gMUYr(HjWDREYsGNjsOYHbsByHkyPvwNirbUB1twcCBGFfpWjThuf4RCKFyIqeQGLwrXIef4RCKFyIqe4wYPJCUax9FLsHQRNLJDqBGtagDLJ8dtG7w9KLahQUEwo2bTbobycvWckWerIc8voYpmricCl50roxGZSjQ(VsPnKd0F((bUs9)GkDLJ8dZetM0ez2eBMsZhz89dCL6p1T61EcC3QNSe4ZjAaF)axP(lublOqOIef4RCKFyIqe4wYPJCUah2S)5QtaMcP2a)k(FabADfGjIstmubUB1twcCBGFf)pGaTUcqOcwqHwfjkWDREYsG)hqGwxbWrKVkWx5i)WeHiublOakisuGdkBFfGGLqf4RCKFCqz7RaeHiWDREYsGNFhCCyG0gwGBz3(JRobykuWsOcCl50roxGtwMmyGJ8tGVYr(HjcrOcwqbwtKOaFLJ8dteIaFLJ8JdkBFfGiebULC6iNlWbLTh4kLIDq1l7mruAImLa3T6jlbE(DWXHbsByboOS9vacwcvOcwqbutKOahu2(kablHkWx5i)4GY2xbicrG7w9KLaptKqLddK2Wc8voYpmricvWckWuIef4RCKFyIqe4wYPJCUax9FLsp7YDc70voYpmteTjI0Zz6zxUtyN2Bmr0MispNPND5oHDkzG(vqtmnteovVcasHQBdZr658iMitBIawmtKPnrKEotp7YDc7uO62WcC3QNSe4zIeQCyG0gwOcvGJTS3FvKOGLqfjkWx5i)WeHiWXg0sUg9KLaN1R0ri9g1eLzt06qfsf4UvpzjWr1vyCyWCIqfS0QirboOS9vacwcvGVYr(XbLTVcqeIa3T6jlboS5iNIk)dpcKdqC7e4RCKFyIqeQGfuqKOa3T6jlbEJupzjWx5i)WeHiublSMirbUB1twc8oC8thiuGVYr(HjcrOcwqnrIc8voYpmricCl50roxG3IjYSjQ(VsP7h4k1FoY7qLUYr(HzIPBIOnrMnr9SHVcWerBImBIntPqvsa57h4k1FQB1R9mr0MylMiSz)ZvNamfsTb(v8)ac06katmntefmXKjnr1)vkf0H6iCzMRbJVFGRuiDLJ8dZetM0ej9Azjbyuyy2riZdpcKNVryNJnWdo6yv)AAgMjMUa3T6jlbE(DWXHbsByHkyHPejkWx5i)WeHiWDREYsG3qoqjb78NJkV9e4wYPJCUaNztePNZ0gYbkjyN)Cu5ThT3yIOnXwmrMnXMPuOkjG89dCL6p1T61EMyYKMiSz)ZvNamfsTb(v8)ac06katmntefmr0MispNPO6kmoqhQuO62WMyAMyRmXetM0eHY(JCfg9NJXryNpuhoyZp6kh5hMjMUjI2eBXeHn7FU6eGPqQnWVI)hqGwxbyIPzIOMjMmPjQ(VsPGouhHlZCny89dCLcPRCKFyMyYKMiPxlljaJcdZoczE4rG88nc7CSbEWrhR6xtZWmXKjnrOS)ixHr)5yCe25d1Hd28JUYr(HzIPlWTSB)XvNamfkyjuHkyb1lsuGVYr(HjcrGBjNoY5cCMnr9SHVcWerBITyImBIntPqvsa57h4k1FQB1R9mXKjnryZ(NRobykKAd8R4)beO1vaMyAMikyIOnrKEotr1vyCGouPq1THnX0mXwzIjMUjI2eBXeHn7FU6eGPqQnWVI)hqGwxbyIPzIOGjMmPjQ(VsPGouhHlZCny89dCLcPRCKFyMyYKMiPxlljaJcdZoczE4rG88nc7CSbEWrhR6xtZWmX0f4UvpzjWZVdoomqAdlublSorIcC3QNSe45Jm((bUs9xGVYr(HjcrOcwqXIef4UvpzjWbNojrGVYr(HjcrOcwcLjIef4RCKFyIqe4wYPJCUaNztu9FLsDODfMx2rx5i)WmXKjnrKEotDODfMx2r7nMyYKMOvkFmjQkQdTRW8YokzG(vqteLMiQXebUB1twcCKxkX45oHDHkyj0qfjkWx5i)WeHiWTKth5CboZMO6)kL6q7kmVSJUYr(HzIjtAIi9CM6q7kmVSJ2Be4UvpzjWrgbos4RaeQGLqBvKOaFLJ8dteIa3soDKZf4mBIQ)RuQdTRW8Yo6kh5hMjMmPjI0ZzQdTRW8YoAVXetM0eTs5JjrvrDODfMx2rjd0VcAIO0ernMiWDREYsGNpYqEPetOcwcffejkWx5i)WeHiWTKth5CboZMO6)kL6q7kmVSJUYr(HzIjtAIi9CM6q7kmVSJ2BmXKjnrRu(ysuvuhAxH5LDuYa9RGMiknruJjcC3QNSe4Ezhuj(ZT()cvWsOSMirb(kh5hMiebULC6iNlWz2ev)xPuhAxH5LD0voYpmtmzstKztePNZuhAxH5LD0EJa3T6jlboIdWLzUsoByOqfSekQjsuG7w9KLaV9GnJWvPoqb(kh5hMieHkyjuMsKOaFLJ8dteIa3soDKZf4wz7vEP06acuE2NjI2eBXez2ev)xPuqhQJWLzUgm((bUsH0voYpmtmzstePNZuqhQJWLzUgm((bUsH0EJjMUjI2eHn7FU6eGPqQnWVI)hqGwxbyIPzIOGa3T6jlbE2hxjEbZD4jlHkyjuuVirb(kh5hMiebULC6iNlWDREThF1aVbnruAITAIOnXwmryZ(NRobykKAd8R4)beO1vaMiknXwnXKjnryZ(NRobykK(EBNJmh0erPj2QjMUa3T6jlboPxC3QNS4)bvb(FqLxo4e4UCcvWsOSorIc8voYpmricCl50roxGZSjQ(VsPqvsa57h4k1F6kh5hMjI2eDREThF1aVbnX0yyITkWHk5SQGLqf4UvpzjWj9I7w9Kf)pOkW)dQ8YbNahEfWpU6eGPcvWsOOyrIc8voYpmricCl50roxGR(VsPqvsa57h4k1F6kh5hMjI2eDREThF1aVbnX0yyITkWHk5SQGLqf4UvpzjWj9I7w9Kf)pOkW)dQ8YbNahoo8kGFC1jatfQqf4nKzLGiUksuWsOIef4RCKFyIqe4UvpzjWNt0a((bUs9xGJnOLCn6jlbokkuhZ21HzIR9iSBI6botudMj6wvsmXdAIEB)Eh5hvGBjNoY5cCMnr1)vkTHCG(Z3pWvQ)huPRCKFycvWsRIef4RCKFyIqe4UvpzjWHQKagERzebo2GwY1ONSe4OUaNjIRscy4TMrmXgYSsqexnXE9dcnrOeCMOJHbnruD)BIWghvLjcLYIkWTKth5CbU6)kLcvjbm8wZi0voYpmteTj2Ijs8dJV2RuQJHbPwzVutmntefmXKjnrIFy81ELsDmmi9kteLMiQXetmDHkybfejkWDREYsGNpY47h4k1Fb(kh5hMieHkyH1ejkWx5i)WeHiWTKth5CbU6)kLUFGRu)5iVdv6kh5hMjI2eHn7FU6eGPqQnWVI)hqGwxbyIPzIOGa3T6jlb((bUs9NJ8oufQGfutKOaFLJ8dteIa3T6jlb(7TDosNavb(F14wmbokiWTKth5CboZMO6)kLUFGRu)5iVdv6kh5hMjI2eHn7FU6eGPqQnWVI)hqGwxbyIPzIOGjMmPjI0ZzkuLeWWBnJq7ncCSbTKRrpzjWdzwVdNjY6RDiMyGdnr3evI3EVjQh4sWe1GzIogMSmXM3TdAImTgCqtCLsyNPnrzzIOorD1eZsIjIcMiCwzHbnrvAIEB5HzIyYoYpu0S(AhIjkltSP)pvOcwykrIc8voYpmricCl50roxGZSjQ(VsP7h4k1FoY7qLUYr(HzIOnryZ(NRobykKAd8R4)beO1vaMikzyIOGjI2ez2er65mfQscy4TMrO9gbUB1twcCBGFf)pGaTUcqOcwq9Ief4UvpzjWBK6jlb(kh5hMieHkubUlNirblHksuG7w9KLahQsciF)axP(lWx5i)WeHiublTksuGVYr(HjcrGBjNoY5cCKEotT()8)ac06kakzG(vqteLmmXqzIa3T6jlb(yFCzMRbJdvjbuOcwqbrIc8voYpmricCl50roxGJ0Zz6SbYRa4WaPnmT3iWDREYsGpNObSQ7HNqfSWAIef4UvpzjWTb(v8aN0EqvGVYr(HjcrOcwqnrIc8voYpmricCl50roxGR(VsPqvsadV1mcDLJ8dtG7w9KLahQscy4TMreQGfMsKOaFLJ8dteIa3T6jlbE(DWXHbsBybULC6iNlWjltgmWr(zIOnXwmXwmr3Qx7XXKkn)o44WaPnSjMMj2QjI2eDREThF1aVbnX0yyIOGjI2eTs5JjrvrBihOKGD(ZrL3EuYa9RGMyAMyOmLjI2eTY2R8sP1Se5ljyMiAtKztSzkfQsciF)axP(tDRETNjMmPj6w9ApoMuP53bhhgiTHnX0mXqnr0MOB1R94Rg4nOjIsgMiRzIOnrMnXMPuOkjG89dCL6p1T61EMiAtu9FLsbDOocxM5AW47h4kfsx5i)WmX0nXKjnXwmrsVwwsagfgMDeY8WJa55Be25yd8GJow1VMMHzIOnrMnXMPuOkjG89dCL6p1T61EMy6My6cCl72FC1jatHcwcvOcwq9Ief4RCKFyIqe4wYPJCUaNzt0T61ECmPsZVdoomqAdBIOnrMnXMPuOkjG89dCL6p1T61EMiAtSftu9FLsbDOocxM5AW47h4kfsx5i)WmXKjnrsVwwsagfgMDeY8WJa55Be25yd8GJow1VMMHzIPlWDREYsGNFhCCyG0gwOcwyDIef4RCKFyIqe4wYPJCUax9FLsNnqEfahgiTHPRCKFyMiAte03dvIe0erjdtKPyIjI2eBXej9Azjby0zdKdYLzoazUYH9cBKRaOJv9RPzyMiAtePNZ0zdKdYLzoazUYH9cBKRaO9gtmzstKztK0RLLeGrNnqoixM5aK5kh2lSrUcGow1VMMHzIPlWDREYsGpBG8kaomqAdlublOyrIc8voYpmricCl50roxGR(VsPo0UcZl7ORCKFyMiAtSftKztSzkfQsciF)axP(tDRETNjMUjI2eBXez2ev)xP0ZUCNWoDLJ8dZetM0ez2er65m9Sl3jSt7nMiAtKzt0kLpMevf9Sl3jSt7nMy6cC3QNSe4o0UcZl7eQGLqzIirb(kh5hMiebULC6iNlWv)xP0)yv)W4GoaOZvPoq6kh5hMa3T6jlb(FSQFyCqha05QuhOqfSeAOIef4RCKFyIqe4wYPJCUah2S)5QtaMcP2a)k(FabADfGjMMjYAMiAtePNZuqhQJWLzUgm((bUsH0EJjI2eb99qLibnX0mruJjcC3QNSe42a)k(FabADfGqfSeARIef4RCKFyIqe4wYPJCUaN0RLLeGrNnqoixM5aK5kh2lSrUcGow1VMMHzIOnrMnrKEotNnqoixM5aK5kh2lSrUcG2Be4UvpzjWNt0aomqAdlublHIcIef4RCKFyIqe4wYPJCUahtQ087GJddK2WuYa9RGMiAte2S)5QtaMcP2a)k(FabADfGjMMjYAMiAtSftKztSzkfQsciF)axP(tDRETNjMUjI2eBXer65m992oh2jaJ2Bmr0MiZMispNPGouhHlZCny89dCLcP9gteTjQ(VsPGouhHlZCny89dCLcPRCKFyMy6cC3QNSe4V325iDcufQGLqznrIc8voYpmricCl50roxGdB2)C1jatHuBGFf)pGaTUcWerjdtSvteTjYSjs61YscWOZgihKlZCaYCLd7f2ixbqhR6xtZWmr0MylMO6)kLc6qDeUmZ1GX3pWvkKUYr(HzIOnrqFpujsqteLmmruJjMiAtKztePNZuqhQJWLzUgm((bUsH0EJjMUa3T6jlb(CIgWQUhEcvWsOOMirb(kh5hMiebULC6iNlWXKkn)o44WaPnmLmq)kOjI2er65m992oh2jaJ2Bmr0MispNPnKdusWo)5OYBpAVrG7w9KLa)92ohPtGQqfSektjsuGVYr(HjcrGBjNoY5cCmPsZVdoomqAdtjd0VcAIOnryZ(NRobykKAd8R4)beO1vaMyAMiRzIOnrsVwwsagfgMDeY8WJa55Be25yd8GJow1VMMHzIOnrKEotFVTZHDcWO9gteTjQ(VsPGouhHlZCny89dCLcPRCKFyMiAtKztePNZuqhQJWLzUgm((bUsH0EJjI2eb99qLibnruYWernMiWDREYsG)EBNJ0jqvOcwcf1lsuGVYr(HjcrGBjNoY5cCmPsZVdoomqAdtjd0VcAIOnXwmXwmryZ(NRobykKAd8R4)beO1vaMyAMiRzIOnrsVwwsagfgMDeY8WJa55Be25yd8GJow1VMMHzIOnr1)vkf0H6iCzMRbJVFGRuiDLJ8dZet3etM0eBXev)xPuqhQJWLzUgm((bUsH0voYpmteTjc67HkrcAIOKHjIAmXerBImBIi9CMc6qDeUmZ1GX3pWvkK2Bmr0MylMiZMiPxlljaJoBGCqUmZbiZvoSxyJCfaDSQFnndZetM0er65mD2a5GCzMdqMRCyVWg5kaAVXet3erBImBIKETSKamkmm7iK5HhbYZ3iSZXg4bhDSQFnndZet3etxG7w9KLa)92ohPtGQqfSekRtKOaFLJ8dteIa3soDKZf4ysLMFhCCyG0gMsgOFf0erBIWM9pxDcWui1g4xX)diqRRamrgMiRzIOnrsVwwsagfgMDeY8WJa55Be25yd8GJow1VMMHzIOnrKEotFVTZHDcWO9gteTjQ(VsPGouhHlZCny89dCLcPRCKFyMiAtKztePNZuqhQJWLzUgm((bUsH0EJjI2eb99qLibnruYWernMiWDREYsG)EBNJ0jqvOcwcfflsuGVYr(HjcrGBjNoY5cCyZ(NRobykKAd8R4)beO1vaMikzyITkWDREYsGpNObSQ7HNqfS0ktejkWx5i)WeHiWTKth5CbospNPqvsadV1mcLmq)kOjMMjIcMitBIawmtKPnrKEotHQKagERzekuDBybUB1twcCBGFf)pGaTUcqOcwAnurIc8voYpmricCl50roxGJ0Zz67TDoStagT3yIOnryZ(NRobykKAd8R4)beO1vaMyAMiRzIOnXwmrMnXMPuOkjG89dCL6p1T61EMy6MiAtetQ087GJddK2Wu9SHVcqG7w9KLa)92ohPtGQqfS0ARIef4RCKFyIqe4wYPJCUax9FLs3pWvQ)CK3HkDLJ8dZerBIWM9pxDcWui1g4xX)diqRRamX0mruZerBITyImBIntPqvsa57h4k1FQB1R9mX0f4UvpzjW3pWvQ)CK3HQqfS0kkisuGVYr(HjcrGBjNoY5cC1)vk1H2vyEzhDLJ8dtG7w9KLa)92ohzoOqfS0kRjsuG7w9KLa3g4xX)diqRRae4RCKFyIqeQGLwrnrIc8voYpmric8voYpoOS9vaIqe4wYPJCUahPNZ03B7CyNamAVXerBIwP8XKOQ4K5wvG7w9KLa)92ohPtGQahu2(kablHkublTYuIef4GY2xbiyjub(kh5hhu2(karicC3QNSe453bhhgiTHf4w2T)4QtaMcfSeQa3soDKZf4KLjdg4i)e4RCKFyIqeQGLwr9Ief4GY2xbiyjub(kh5hhu2(karicC3QNSe4zIeQCyG0gwGVYr(HjcrOcvGdhhEfWpU6eGPIefSeQirbUB1twcCOkjG89dCL6VaFLJ8dteIqfS0Qirb(kh5hMiebULC6iNlWr65m16)Z)diqRRaOKb6xbnruYWedLjcC3QNSe4J9XLzUgmouLeqHkybfejkWx5i)WeHiWTKth5CbU6)kLE2L7e2PRCKFyMiAtePNZ0ZUCNWoT3yIOnrKEotp7YDc7uYa9RGMyAMiCQEfaKcv3gMJ0Z5rmrM2ebSyMitBIi9CME2L7e2Pq1THnr0MispNPO6kmoqhQuO62WMyAMyOSobUB1twc8mrcvomqAdlublSMirb(kh5hMiebULC6iNlWv)xP09dCL6ph5DOsx5i)We4UvpzjW3pWvQ)CK3HQqfSGAIef4RCKFyIqe4wYPJCUax9FLsHQKagERze6kh5hMa3T6jlbouLeWWBnJiublmLirb(kh5hMiebULC6iNlWv)xP0zdKxbWHbsBy6kh5hMjI2eTs5JjrvrFVTZr6eOsjd0VcAIPXWebSyMiAte2S)5QtaMcP2a)k(FabADfGjMMj2QjMmPjc67HkrcAIOKHjYumXerBIWM9pxDcWui1g4xX)diqRRamruYWeB1erBITyImBIKETSKam6SbYb5YmhGmx5WEHnYva0XQ(10mmtmzstePNZ0zdKdYLzoazUYH9cBKRaO9gtmDtmzste2S)5QtaMcP2a)k(FabADfGjMMj2QjI2er65mfvxHXb6qLcv3g2erjdtmuwNjI2eBXez2ej9Azjby0zdKdYLzoazUYH9cBKRaOJv9RPzyMyYKMispNPZgihKlZCaYCLd7f2ixbq7nMy6MiAte03dvIe0erjdtKPyIa3T6jlb(SbYRa4WaPnSqfSG6fjkWx5i)WeHiWTKth5CbElMispNPO6kmoqhQuO62WMyAMyOSoteTjYSjI0ZzkYlLyFhQ0EJjMUjMmPjI0Zz67TDoStagT3iWDREYsG)EBNJ0jqvOcwyDIef4RCKFyIqe4wYPJCUax9FLsNnqEfahgiTHPRCKFyMiAtePNZ0zdKxbWHbsByAVXerBIWM9pxDcWui1g4xX)diqRRamX0mXwf4UvpzjWFVTZr6eOkublOyrIc8voYpmricCl50roxGR(VsPZgiVcGddK2W0voYpmteTjI0Zz6SbYRa4WaPnmT3yIOnryZ(NRobykKAd8R4)beO1vaMikzyITkWDREYsGpNObSQ7HNqfSektejkWx5i)WeHiWTKth5CbospNPqvsadV1mcT3iWDREYsG)hqGwxbWrKVkublHgQirb(kh5hMiebULC6iNlWr65mD2a5GCzMdqMRCyVWg5kaAVrG7w9KLaFordyv3dpHkyj0wfjkWx5i)WeHiWTKth5CboSz)ZvNamfsTb(v8)ac06katmntSvteTjc67HkrcAIOKHjYumXerBITyIi9CMIQRW4aDOsHQBdBIPzITYetmzste03dvIe0erPjIIzIjMUjMmPj2Ijs61YscWOZgihKlZCaYCLd7f2ixbqhR6xtZWmr0MiZMispNPZgihKlZCaYCLd7f2ixbq7nMy6cC3QNSe4ZjAahgiTHfQGLqrbrIc8voYpmricCl50roxG3IjcB2)C1jatHuBGFf)pGaTUcWerPjgQjMUjI2eBXez2eXKkn)o44WaPnmLSmzWah5NjMUa3T6jlb(CIgWQUhEcvWsOSMirb(kh5hMiebULC6iNlWDREThF1aVbnruAIHAIOnXMPuOkjG89dCL6p1T61EMiAtePNZuKxkX(ouP9gbUB1twcCBGFf)pGaTUcqOcwcf1ejkWx5i)WeHiWTKth5CbEZukuLeq((bUs9N6w9ApteTjI0ZzkYlLyFhQ0EJa3T6jlb(FabADfahr(QqfSektjsuGVYr(HjcrGBjNoY5cCKEotDODfMx2r7ncC3QNSe4V325iDcufQGLqr9Ief4RCKFyIqe4wYPJCUa3kLpMevfNm3QcC3QNSe4V325iDcufQGLqzDIef4RCKFyIqe4wYPJCUa3kLpMevfNm3QMiAt0g4eGbnruAIQ)Ru6SbsUmZ1GX3pWvkKUYr(HjWDREYsG)EBNJ0jqvOcwcfflsuGVYr(HjcrGBjNoY5cC1)vk9Sl3jStx5i)Wmr0MispNPND5oHDAVrG7w9KLaptKqLddK2WcvWsRmrKOa3T6jlbUnWVIh4K2dQc8voYpmricvWsRHksuGVYr(HjcrGBjNoY5cC1)vkfQUEwo2bTboby0voYpmbUB1twcCO66z5yh0g4eGjublT2Qirb(kh5hMiebULC6iNlWz2ev)xP0gYb6pF)axP(FqLUYr(HzIjtAIQ)RuAd5a9NVFGRu)pOsx5i)Wmr0MylMiZMyZukuLeq((bUs9N6w9AptmDbUB1twc85enGVFGRu)fQGLwrbrIc8voYpmricCl50roxG7w9Ap(QbEdAIO0ed1erBITyIWM9pxDcWui1g4xX)diqRRamruAIHAIjtAIWM9pxDcWui992ohzoOjIstmutmDbUB1twcCBGFf)pGaTUcqOcwAL1ejkWDREYsG)hqGwxbWrKVkWx5i)WeHiublTIAIef4GY2xbiyjub(kh5hhu2(karicC3QNSe453bhhgiTHf4w2T)4QtaMcfSeQa3soDKZf4KLjdg4i)e4RCKFyIqeQGLwzkrIc8voYpmric8voYpoOS9vaIqe4wYPJCUahu2EGRuk2bvVSZerPjYucC3QNSe453bhhgiTHf4GY2xbiyjuHkyPvuVirboOS9vacwcvGVYr(XbLTVcqeIa3T6jlbEMiHkhgiTHf4RCKFyIqeQqfQqfQqa]] )

end
