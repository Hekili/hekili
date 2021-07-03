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


            timeToReady = function ()
                return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.storm_elemental.remains, pet.primal_storm_elemental.remains )
            end,            

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

            timeToReady = function ()
                return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.fire_elemental.remains, pet.primal_fire_elemental.remains )
            end,            

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

    spec:RegisterPack( "Elemental", 20210703, [[diet9bqiuupskPytq0OKsCkrQwfks9krsZseClPKsTlK(LiXWqrCmbPLbbEMusMgeQUgekBdLQ8nuK04qPQ6COiX6qPQuZtKY9qH9bbDqPKQYcfepukPstukPkDrPKsojkvfReL0mrPQKBkLuvTtuINcvtve6QsjvXEj8xunyHomvlgspMstgkxwzZI6ZagTaNwLxlOMTQUnq7wYVjA4sXXrPYYr8CqtN01LQTlL67qiJxkPIZJsz(IO9tXIqfjkWXCDcwqatqqOmHPYKwrdTvHI4mbXf4kBntG342WoWe4LdobER1pWvQ)c8gNTx6yIef4qzNyNapq1gi77usb40Gok1kbtbEG931twwIN1uGhOnfboA)EL9PeOcCmxNGfeWeeektyQmPv0qBvOTcXykcCyZScwqa7HabEWHHTsGkWXg0kWBT(bUs93eXdCqVmSYA)zZeBvcMicyccc1WQH1w3aVagK9TH1wBtK9PSssJK46mr4u9kaifQUnmhTNZJyIzjXezFSl3jSLGjIRscy4TMrOgwBTnXwFyyMyR)PtsmrVWmXwl2MjkZMOgmtexLeqt0b8ROc8gImF)e4TMwJj2A9dCL6VjIh4GEzyT10Amrw7pBMyRsWeratqqOgwnS2AAnMyRBGxadY(2WARP1yIT2Mi7tzLKgjX1zIWP6vaqkuDByoApNhXeZsIjY(yxUtylbtexLeWWBnJqnS2AAnMyRTj26ddZeB9pDsIj6fMj2AX2mrz2e1GzI4QKaAIoGFf1WQH1wJj2A16mBxhMjU2JWMjQh4mrnyMOBvjXepOj6T97D0FudRUvpzbPnKzLGOUYyord47h4k1)eUmdMv)xP0gYb6pF)axP(FqLUYr)HzyT1yITEGZeXvjbm8wZiMydzwjiQRMyV(bHMiucot0XWGMiIU)nryJJOYeHszrnS6w9KfK2qMvcI6AQmsbQscy4TMrs4Ymu)xPuOkjGH3AgHUYr)HHSfIFy81ELsDmmi1k7LMwRsMK4hgFTxPuhddsVcHigts3WQB1twqAdzwjiQRPYiL8rgF)axP(By1T6jliTHmRee11uzKY(bUs9NJ(out4Ymu)xP09dCL6ph9DOsx5O)WqcB2)C1jatHuBGFf)pGaTUciTwzyT1yIHmR3HZezF1oetmWHMOBIkXBV3e1dCjyIAWmrhdtwMyZ72bnrMwdoOjUsjSX0MOSmXw3wVMywsmXwzIWzLfg0evPj6TLhMjIj7O)ATzF1oetuwMyt)FQHv3QNSG0gYSsquxtLrkV325ODcut4VAClgJwLWLzWS6)kLUFGRu)5OVdv6kh9hgsyZ(NRobykKAd8R4)beO1vaP1QKjr75mfQscy4TMrO9gdRUvpzbPnKzLGOUMkJuSb(v8)ac06kGeUmdMv)xP09dCL6ph9DOsx5O)WqcB2)C1jatHuBGFf)pGaTUcaHmAfsMr75mfQscy4TMrO9gdRUvpzbPnKzLGOUMkJuAK6jldRgwBnMi7tPJq6nQjkZMO1HkKAy1T6jlyQmsbrxHXHbZjgwDREYcMkJuGnh5ue5F4rGCaIBxcGY2xbWiudRUvpzbtLrkns9KLHv3QNSGPYiLoC8thi0WQB1twWuzKs(DWXHbsB4eUmJwyw9FLs3pWvQ)C03HkDLJ(dlDKmRNn8vaizUzkfQsciF)axP(tDREThYwGn7FU6eGPqQnWVI)hqGwxbKwRsMu9FLsbDOocxM5AW47h4kfsx5O)WsMK0RLLeGrHHzdLmp8iqE(gHno2ap4OJD9RPzyPBy1T6jlyQmsPHCGsc25phrE7LGLn7pU6eGPqgHMWLzWmApNPnKdusWo)5iYBpAVbzlm3mLcvjbKVFGRu)PUvV2lzsyZ(NRobykKAd8R4)beO1vaP1kKO9CMIORW4aDOsHQBdNgcysYKqz)rVcJ(ZX4OSXxRJd28JUYr)HLoYwGn7FU6eGPqQnWVI)hqGwxbKgILmP6)kLc6qDeUmZ1GX3pWvkKUYr)HLmjPxlljaJcdZgkzE4rG88ncBCSbEWrh76xtZWsMek7p6vy0FoghLn(ADCWMF0vo6pS0nS6w9KfmvgPKFhCCyG0goHlZGz9SHVcazlm3mLcvjbKVFGRu)PUvV2lzsyZ(NRobykKAd8R4)beO1vaP1kKO9CMIORW4aDOsHQBdNgcys6iBb2S)5QtaMcP2a)k(FabADfqATkzs1)vkf0H6iCzMRbJVFGRuiDLJ(dlzssVwwsagfgMnuY8WJa55Be24yd8GJo21VMMHLUHv3QNSGPYiL8rgF)axP(By1T6jlyQmsbC6KedRUvpzbtLrkOVuIXZDcBjCzgmR(VsPo0UcZl7ORC0FyjtI2ZzQdTRW8YoAVjzsRu(ysevuhAxH5LDuYa9RGieXyIHv3QNSGPYif0rGJe(kGeUmdMv)xPuhAxH5LD0vo6pSKjr75m1H2vyEzhT3yy1T6jlyQmsjFKH(sjwcxMbZQ)RuQdTRW8Yo6kh9hwYKO9CM6q7kmVSJ2BsM0kLpMerf1H2vyEzhLmq)kicrmMyy1T6jlyQmsXl7GkXFU1)pHlZGz1)vk1H2vyEzhDLJ(dlzs0EotDODfMx2r7njtALYhtIOI6q7kmVSJsgOFfeHigtmS6w9KfmvgPG6aCzMRKZggMWLzWS6)kL6q7kmVSJUYr)HLmjZO9CM6q7kmVSJ2BmS6w9KfmvgP0EWMr4QuhOHv3QNSGPYiLSpUs8cM7WtwjCzgwz7vEP06acuE2hYwyw9FLsbDOocxM5AW47h4kfsx5O)WsMeTNZuqhQJWLzUgm((bUsH0Et6iHn7FU6eGPqQnWVI)hqGwxbKwRmS6w9KfmvgPq6f3T6jl(FqnHYbhdxUeUmd3Qx7XxnWBqeIaKTaB2)C1jatHuBGFf)pGaTUcaHiizsyZ(NRobykK(EBNJoheHiiDdRUvpzbtLrkKEXDREYI)hutOCWXaEfWpU6eGPjavYzvgHMWLzWS6)kLcvjbKVFGRu)PRC0FyiDREThF1aVbtJbcmS6w9KfmvgPq6f3T6jl(FqnHYbhd44WRa(XvNamnbOsoRYi0eUmd1)vkfQsciF)axP(tx5O)Wq6w9Ap(QbEdMgdeyy1WQB1twqQlhdOkjG89dCL6VHv3QNSGuxUuzKYyBCzMRbJdvjbmHlZaTNZuR)p)pGaTUcGsgOFfeHmcLjgwDREYcsD5sLrkZjAa76E4LWLzG2Zz6SbYRa4WaPnmT3yy1T6jli1LlvgPyd8R4boP9GQHv3QNSGuxUuzKcuLeWWBnJKWLzO(VsPqvsadV1mcDLJ(dZWQB1twqQlxQmsj)o44WaPnCcw2S)4QtaMczeAcxMbzzYGbo6pKT0IB1R94ysLMFhCCyG0goneG0T61E8vd8gmngTcPvkFmjIkAd5aLeSZFoI82JsgOFfmTqzpKwz7vEP0AwI8LemKm3mLcvjbKVFGRu)PUvV2lzs3Qx7XXKkn)o44WaPnCAHI0T61E8vd8geHmqCKm3mLcvjbKVFGRu)PUvV2dP6)kLc6qDeUmZ1GX3pWvkKUYr)HLEYKTq61YscWOWWSHsMhEeipFJWghBGhC0XU(10mmKm3mLcvjbKVFGRu)PUvV2l90nS6w9KfK6YLkJuYVdoomqAdNWLzWSB1R94ysLMFhCCyG0ggjZntPqvsa57h4k1FQB1R9q2I6)kLc6qDeUmZ1GX3pWvkKUYr)HLmjPxlljaJcdZgkzE4rG88ncBCSbEWrh76xtZWs3WQB1twqQlxQmsz2a5vaCyG0goHlZq9FLsNnqEfahgiTHPRC0Fyib99qLibrid2JjiBH0RLLeGrNnqoixM5aK5kh2lSrUcGo21VMMHHeTNZ0zdKdYLzoazUYH9cBKRaO9MKjzM0RLLeGrNnqoixM5aK5kh2lSrUcGo21VMMHLUHv3QNSGuxUuzKIdTRW8YUeUmd1)vk1H2vyEzhDLJ(ddzlm3mLcvjbKVFGRu)PUvV2lDKTWS6)kLE2L7e2ORC0FyjtYmApNPND5oHnAVbjZwP8XKiQOND5oHnAVjDdRUvpzbPUCPYiL)yx)W4GoaOZvPoWeUmd1)vk9p21pmoOda6CvQdKUYr)Hzy1T6jli1LlvgPyd8R4)beO1vajCzgWM9pxDcWui1g4xX)diqRRasdXrI2ZzkOd1r4YmxdgF)axPqAVbjOVhQejyAigtmS6w9KfK6YLkJuMt0aomqAdNWLzq61YscWOZgihKlZCaYCLd7f2ixbqh76xtZWqYmApNPZgihKlZCaYCLd7f2ixbq7ngwDREYcsD5sLrkV325ODcut4YmWKkn)o44WaPnmLmq)kisyZ(NRobykKAd8R4)beO1vaPH4iBH5MPuOkjG89dCL6p1T61EPJSf0EotFVTZHDcWO9gKmJ2ZzkOd1r4YmxdgF)axPqAVbP6)kLc6qDeUmZ1GX3pWvkKUYr)HLUHv3QNSGuxUuzKYCIgWUUhEjCzgWM9pxDcWui1g4xX)diqRRaqideGKzsVwwsagD2a5GCzMdqMRCyVWg5ka6yx)AAggYwu)xPuqhQJWLzUgm((bUsH0vo6pmKG(EOsKGiKbIXeKmJ2ZzkOd1r4YmxdgF)axPqAVjDdRUvpzbPUCPYiL3B7C0obQjCzgysLMFhCCyG0gMsgOFfejApNPV325Woby0Eds0EotBihOKGD(ZrK3E0EJHv3QNSGuxUuzKY7TDoANa1eUmdmPsZVdoomqAdtjd0VcIe2S)5QtaMcP2a)k(FabADfqAiossVwwsagfgMnuY8WJa55Be24yd8GJo21VMMHHeTNZ03B7CyNamAVbP6)kLc6qDeUmZ1GX3pWvkKUYr)HHKz0EotbDOocxM5AW47h4kfs7nib99qLibrideJjgwDREYcsD5sLrkV325ODcut4YmWKkn)o44WaPnmLmq)kiYwAb2S)5QtaMcP2a)k(FabADfqAiossVwwsagfgMnuY8WJa55Be24yd8GJo21VMMHHu9FLsbDOocxM5AW47h4kfsx5O)WspzYwu)xPuqhQJWLzUgm((bUsH0vo6pmKG(EOsKGiKbIXeKmJ2ZzkOd1r4YmxdgF)axPqAVbzlmt61YscWOZgihKlZCaYCLd7f2ixbqh76xtZWsMeTNZ0zdKdYLzoazUYH9cBKRaO9M0rYmPxlljaJcdZgkzE4rG88ncBCSbEWrh76xtZWspDdRUvpzbPUCPYiL3B7C0obQjCzgysLMFhCCyG0gMsgOFfejSz)ZvNamfsTb(v8)ac06kagiossVwwsagfgMnuY8WJa55Be24yd8GJo21VMMHHeTNZ03B7CyNamAVbP6)kLc6qDeUmZ1GX3pWvkKUYr)HHKz0EotbDOocxM5AW47h4kfs7nib99qLibrideJjgwDREYcsD5sLrkZjAa76E4LWLzaB2)C1jatHuBGFf)pGaTUcaHmqGHv3QNSGuxUuzKInWVI)hqGwxbKWLzG2ZzkuLeWWBnJqjd0VcMwRyAalgtJ2ZzkuLeWWBnJqHQBdBy1T6jli1LlvgP8EBNJ2jqnHlZaTNZ03B7CyNamAVbjSz)ZvNamfsTb(v8)ac06kG0qCKTWCZukuLeq((bUs9N6w9AV0rIjvA(DWXHbsByQE2Wxbyy1T6jli1LlvgPSFGRu)5OVd1eUmd1)vkD)axP(ZrFhQ0vo6pmKWM9pxDcWui1g4xX)diqRRasdXq2cZntPqvsa57h4k1FQB1R9s3WQB1twqQlxQms592ohDoycxMH6)kL6q7kmVSJUYr)Hzy1T6jli1LlvgPyd8R4)beO1vagwDREYcsD5sLrkV325ODcutau2(kagHMWLzG2Zz67TDoStagT3G0kLpMerfNm3QgwDREYcsD5sLrk53bhhgiTHtau2(kagHMGLn7pU6eGPqgHMWLzqwMmyGJ(ZWQB1twqQlxQmsjtKqLddK2WjakBFfaJqnSAy1T6jlifoo8kGFC1jatzavjbKVFGRu)nS6w9KfKchhEfWpU6eGPPYiLX24YmxdghQscycxMbApNPw)F(FabADfaLmq)kiczektmS6w9KfKchhEfWpU6eGPPYiLmrcvomqAdNWLzO(VsPND5oHn6kh9hgs0Eotp7YDcB0Eds0Eotp7YDcBuYa9RGPbNQxbaPq1TH5O9CEeMgWIX0O9CME2L7e2Oq1THrI2ZzkIUcJd0HkfQUnCAHY(nS6w9KfKchhEfWpU6eGPPYiL9dCL6ph9DOMWLzO(VsP7h4k1Fo67qLUYr)Hzy1T6jlifoo8kGFC1jattLrkqvsadV1mscxMH6)kLcvjbm8wZi0vo6pmdRUvpzbPWXHxb8JRobyAQmsz2a5vaCyG0goHlZq9FLsNnqEfahgiTHPRC0FyiTs5JjrurFVTZr7eOsjd0VcMgdalgsyZ(NRobykKAd8R4)beO1vaPHGKjb99qLibrid2JjiHn7FU6eGPqQnWVI)hqGwxbGqgiazlmt61YscWOZgihKlZCaYCLd7f2ixbqh76xtZWsMeTNZ0zdKdYLzoazUYH9cBKRaO9M0tMe2S)5QtaMcP2a)k(FabADfqAiajApNPi6kmoqhQuO62WiKrOSFKTWmPxlljaJoBGCqUmZbiZvoSxyJCfaDSRFnndlzs0EotNnqoixM5aK5kh2lSrUcG2BshjOVhQejiczWEmXWQB1twqkCC4va)4QtaMMkJuEVTZr7eOMWLz0cApNPi6kmoqhQuO62WPfk7hjZO9CMI(sj23HkT3KEYKO9CM(EBNd7eGr7ngwDREYcsHJdVc4hxDcW0uzKY7TDoANa1eUmd1)vkD2a5vaCyG0gMUYr)HHeTNZ0zdKxbWHbsByAVbjSz)ZvNamfsTb(v8)ac06kG0qGHv3QNSGu44WRa(XvNamnvgPmNObSR7HxcxMH6)kLoBG8kaomqAdtx5O)WqI2Zz6SbYRa4WaPnmT3Ge2S)5QtaMcP2a)k(FabADfaczGadRUvpzbPWXHxb8JRobyAQms5pGaTUcGJkFnHlZaTNZuOkjGH3AgH2BmS6w9KfKchhEfWpU6eGPPYiL5enGDDp8s4Ymq75mD2a5GCzMdqMRCyVWg5kaAVXWQB1twqkCC4va)4QtaMMkJuMt0aomqAdNWLzaB2)C1jatHuBGFf)pGaTUcineGe03dvIeeHmypMGSf0Eotr0vyCGouPq1THtdbmjzsqFpujsqeYuys6jt2cPxlljaJoBGCqUmZbiZvoSxyJCfaDSRFnnddjZO9CMoBGCqUmZbiZvoSxyJCfaT3KUHv3QNSGu44WRa(XvNamnvgPmNObSR7HxcxMrlWM9pxDcWui1g4xX)diqRRaqyOPJSfMXKkn)o44WaPnmLSmzWah9x6gwDREYcsHJdVc4hxDcW0uzKInWVI)hqGwxbKWLz4w9Ap(QbEdIWqr2mLcvjbKVFGRu)PUvV2djApNPOVuI9DOs7ngwDREYcsHJdVc4hxDcW0uzKYFabADfahv(AcxMrZukuLeq((bUs9N6w9ApKO9CMI(sj23HkT3yy1T6jlifoo8kGFC1jattLrkV325ODcut4Ymq75m1H2vyEzhT3yy1T6jlifoo8kGFC1jattLrkV325ODcut4YmSs5JjruXjZTQHv3QNSGu44WRa(XvNamnvgP8EBNJ2jqnHlZWkLpMerfNm3QiTbobyqeQ(VsPZgi5YmxdgF)axPq6kh9hMHv3QNSGu44WRa(XvNamnvgPKjsOYHbsB4eUmd1)vk9Sl3jSrx5O)WqI2Zz6zxUtyJ2BmS6w9KfKchhEfWpU6eGPPYifBGFfpWjThunS6w9KfKchhEfWpU6eGPPYifO66z5yh0g4eGLWLzO(VsPq11ZYXoOnWjaJUYr)Hzy1T6jlifoo8kGFC1jattLrkZjAaF)axP(NWLzWS6)kL2qoq)57h4k1)dQ0vo6pSKjv)xP0gYb6pF)axP(FqLUYr)HHSfMBMsHQKaY3pWvQ)u3Qx7LUHv3QNSGu44WRa(XvNamnvgPyd8R4)beO1vajCzgUvV2JVAG3GimuKTaB2)C1jatHuBGFf)pGaTUcaHHMmjSz)ZvNamfsFVTZrNdIWqt3WQB1twqkCC4va)4QtaMMkJu(diqRRa4OYxnS6w9KfKchhEfWpU6eGPPYiL87GJddK2WjakBFfaJqtWYM9hxDcWuiJqt4YmiltgmWr)zy1T6jlifoo8kGFC1jattLrk53bhhgiTHtau2(kagHMWLzakBpWvkf7GQx2Hq2ZWQB1twqkCC4va)4QtaMMkJuYeju5WaPnCcGY2xbWiudRgwDREYcsHxb8JRobykJ)ac06kaoQ81eUmJwq75mfQscy4TMrOKb6xbtdovVcasHQBdZr758imnGfJPr75mfQscy4TMrOq1THt3WQB1twqk8kGFC1jattLrkzIeQCyG0goHlZq9FLsp7YDcB0vo6pmKO9CME2L7e2O9gKO9CME2L7e2OKb6xbtdovVcasHQBdZr758imnGfJPr75m9Sl3jSrHQBdBy1T6jlifEfWpU6eGPPYiL87GJddK2WjyzZ(JRobykKrOjCzgTWSE2WxbKmjMuP53bhhgiTHPKb6xbtJbGflzs1)vk1H2vyEzhDLJ(ddjMuP53bhhgiTHPKb6xbtRfRu(ysevuhAxH5LDuYa9RGPI2ZzQdTRW8YokwN46jR0rALYhtIOI6q7kmVSJsgOFfmnepDKTG2Zz67TDoStagT3KmjZO9CMI(sj23HkT3KUHv3QNSGu4va)4QtaMMkJuYVdoomqAdNGLn7pU6eGPqgHMWLzG2ZzAd5aLeSZFoI82J2BqswMmyGJ(ZWQB1twqk8kGFC1jattLrko0UcZl7s4Ymu)xPuhAxH5LD0vo6pmKTOh4qid2JjjtI2Zzk6lLyFhQ0Et6iBXkLpMerf992ohTtGkLmq)kiczs6iBHz1)vk9Sl3jSrx5O)WsMKz0Eotp7YDcB0EdsMTs5Jjrurp7YDcB0Et6gwDREYcsHxb8JRobyAQms592ohTtGAcxMbApNPV325Woby0EdYwi9AzjbyueDfgSzE4rG83B7CYGDcWk7OJD9RPzyjtYmApNPGouhHlZCny89dCLcP9gKQ)RukOd1r4YmxdgF)axPq6kh9hw6gwDREYcsHxb8JRobyAQmsz)axP(ZrFhQjCzgQ)Ru6(bUs9NJ(ouPRC0FyiBb03dvIemnMkts3WQB1twqk8kGFC1jattLrkqvsadV1mscxMH6)kLcvjbm8wZi0vo6pmKTq8dJV2RuQJHbPwzV00AvYKe)W4R9kL6yyq6vieXys6iBb03dvIemnehXt3WQB1twqk8kGFC1jattLrkZgiVcGddK2WjCzgQ)Ru6SbYRa4WaPnmDLJ(ddPvkFmjIk67TDoANavkzG(vW0yayXmS6w9KfKcVc4hxDcW0uzKY7TDoANa1eUmd1)vkD2a5vaCyG0gMUYr)HHeTNZ0zdKxbWHbsByAVXWQB1twqk8kGFC1jattLrk)XU(HXbDaqNRsDGjCzgQ)Ru6FSRFyCqha05QuhiDLJ(dZWQB1twqk8kGFC1jattLrkZjAa76E4LWLzG2Zz6SbYb5YmhGmx5WEHnYva0Eds1)vkf0H6iCzMRbJVFGRuiDLJ(ddjApNPGouhHlZCny89dCLcP9gdRUvpzbPWRa(XvNamnvgP8hqGwxbWrLVMWLzG2ZzkuLeWWBnJq7nir75mf0H6iCzMRbJVFGRuiT3Ge03dvIemn2JjgwDREYcsHxb8JRobyAQmszordyx3dVeUmd0EotNnqoixM5aK5kh2lSrUcG2Bq2I6)kLc6qDeUmZ1GX3pWvkKUYr)HHSf0EotbDOocxM5AW47h4kfs7njtALYhtIOI(EBNJ2jqLsgOFfeHmbjOVhQejiczWuqqYKWM9pxDcWui1g4xX)diqRRasdbir75mfQscy4TMrO9gKwP8XKiQOV325ODcuPKb6xbtJbGfl9Kjzw9FLsbDOocxM5AW47h4kfsx5O)WsM0kLpMerfD)axP(ZrFhQuYa9RGPXaovVcasHQBdZr758imnGfJPrq6gwDREYcsHxb8JRobyAQmszordyx3dVeUmdyZ(NRobykKAd8R4)beO1vaimuKmJjvA(DWXHbsBykzzYGbo6pKmt61YscWOZgihKlZCaYCLd7f2ixbqh76xtZWq2cZQ)RukOd1r4YmxdgF)axPq6kh9hwYKO9CMc6qDeUmZ1GX3pWvkK2BsM0kLpMerf992ohTtGkLmq)kiczcsqFpujsqeYGPGG0nS6w9KfKcVc4hxDcW0uzKY7TDoANa1eUmdRu(ysevCYCRISfMr75mf0H6iCzMRbJVFGRuiT3GeTNZ0ZUCNWgT3KUHv3QNSGu4va)4QtaMMkJuEVTZr7eOMWLzyLYhtIOItMBvK2aNamicv)xP0zdKCzMRbJVFGRuiDLJ(ddjZO9CME2L7e2O9gdRUvpzbPWRa(XvNamnvgP8EBNJ2jqnHlZq9FLsNnqYLzUgm((bUsH0vo6pmKmJ2ZzkOd1r4YmxdgF)axPqAVbjOVhQejiczGymbjZO9CMoBGCqUmZbiZvoSxyJCfaT3yy1T6jlifEfWpU6eGPPYiL5enGddK2WjCzgTq61YscWOZgihKlZCaYCLd7f2ixbqh76xtZWsMe2S)5QtaMcP2a)k(FabADfqAiiDKTO(VsPGouhHlZCny89dCLcPRC0FyizgTNZ0zdKdYLzoazUYH9cBKRaO9gKTG2ZzkOd1r4YmxdgF)axPqAVjzsqFpujsqeYGPGGKjHn7FU6eGPqQnWVI)hqGwxbKgcqI2ZzkuLeWWBnJq7niTs5JjrurFVTZr7eOsjd0VcMgdalw6jtYS6)kLc6qDeUmZ1GX3pWvkKUYr)HLmPvkFmjIk6(bUs9NJ(ouPKb6xbtJbCQEfaKcv3gMJ2Z5ryAalgtJG0nS6w9KfKcVc4hxDcW0uzKsMiHkhgiTHt4Ymu)xP0ZUCNWgDLJ(ddP6)kLc6qDeUmZ1GX3pWvkKUYr)HHeTNZ0ZUCNWgT3GeTNZuqhQJWLzUgm((bUsH0EJHv3QNSGu4va)4QtaMMkJuEVTZr7eOMWLzG2ZzQdTRW8YoAVXWQB1twqk8kGFC1jattLrkV325ODcut4YmSs5JjruXjZTksMv)xPuqhQJWLzUgm((bUsH0vo6pmdRUvpzbPWRa(XvNamnvgPC2L7e2s4Ymu)xP0ZUCNWgDLJ(ddjZTa67HkrcIWwHyiTs5JjrurFVTZr7eOsjd0VcMgdMKUHv3QNSGu4va)4QtaMMkJuYeju5WaPnCcxMH6)kLE2L7e2ORC0Fyir75m9Sl3jSr7niBbTNZ0ZUCNWgLmq)kyAawmMgXzA0Eotp7YDcBuO62WjtI2ZzkuLeWWBnJq7njtYS6)kLc6qDeUmZ1GX3pWvkKUYr)HLUHv3QNSGu4va)4QtaMMkJuEVTZr7eOAy1T6jlifEfWpU6eGPPYiL87GJddK2WjyzZ(JRobykKrOjCzgKLjdg4O)mS6w9KfKcVc4hxDcW0uzKsMiHkhgiTHt4Ymi9Azjby09dCL6pFSRF)HsUoiDSRFnnddjZO9CMUFGRu)5JD97puY1b5ydTNZ0EdsMv)xP09dCL6ph9DOsx5O)WqYS6)kLoBG8kaomqAdtx5O)WmS6w9KfKcVc4hxDcW0uzKInWVIh4K2dQgwDREYcsHxb8JRobyAQmsjtKqLddK2WjCzgQ)Ru6zxUtyJUYr)HHeTNZ0ZUCNWgT3yy1T6jlifEfWpU6eGPPYifO66z5yh0g4eGLWLzO(VsPq11ZYXoOnWjaJUYr)Hzy1T6jlifEfWpU6eGPPYiL5enGVFGRu)t4Ymyw9FLsBihO)89dCL6)bv6kh9hwYKm3mLMpY47h4k1FQB1R9mS6w9KfKcVc4hxDcW0uzKInWVI)hqGwxbKWLzaB2)C1jatHuBGFf)pGaTUcaHHAy1T6jlifEfWpU6eGPPYiL)ac06kaoQ8vdRUvpzbPWRa(XvNamnvgPKFhCCyG0gobqz7RayeAcw2S)4QtaMczeAcxMbzzYGbo6pdRUvpzbPWRa(XvNamnvgPKFhCCyG0gobqz7RayeAcxMbOS9axPuSdQEzhczpdRUvpzbPWRa(XvNamnvgPKjsOYHbsB4eaLTVcGrOgwDREYcsHxb8JRobyAQmsjtKqLddK2WjCzgQ)Ru6zxUtyJUYr)HHeTNZ0ZUCNWgT3GeTNZ0ZUCNWgLmq)kyAWP6vaqkuDByoApNhHPbSymnApNPND5oHnkuDBybE7rGNSeSGaMGGqzc7HaMIahroPUcakWzFaBKeDyMiIzIUvpzzI)bvi1WQa37AGKiWXpW(76jRwxINvb(FqfksuGdVc4hxDcWurIcwcvKOaFLJ(dteIa3soDKZf4TyIO9CMcvjbm8wZiuYa9RGMyAMiCQEfaKcv3gMJ2Z5rmrM2ebSyMitBIO9CMcvjbm8wZiuO62WMy6cC3QNSe4)beO1vaCu5RcvWccejkWx5O)WeHiWTKth5CbU6)kLE2L7e2ORC0FyMisteTNZ0ZUCNWgT3yIinr0Eotp7YDcBuYa9RGMyAMiCQEfaKcv3gMJ2Z5rmrM2ebSyMitBIO9CME2L7e2Oq1THf4UvpzjWZeju5WaPnSqfS0krIc8vo6pmricC3QNSe453bhhgiTHf4wYPJCUaVftKztupB4RamXKjnrmPsZVdoomqAdtjd0VcAIPXWebSyMyYKMO6)kL6q7kmVSJUYr)HzIinrmPsZVdoomqAdtjd0VcAIPzITyIwP8XKiQOo0UcZl7OKb6xbnXunr0EotDODfMx2rX6expzzIPBIinrRu(ysevuhAxH5LDuYa9RGMyAMiIBIPBIinXwmr0EotFVTZHDcWO9gtmzstKzteTNZu0xkX(ouP9gtmDbULn7pU6eGPqblHkubliUirb(kh9hMiebUB1twc887GJddK2WcCl50roxGJ2ZzAd5aLeSZFoI82J2BmrKMizzYGbo6pbULn7pU6eGPqblHkubliMirb(kh9hMiebULC6iNlWv)xPuhAxH5LD0vo6pmtePj2IjQh4mreYWezpMyIjtAIO9CMI(sj23HkT3yIPBIinXwmrRu(ysev03B7C0obQuYa9RGMicnrMyIPBIinXwmrMnr1)vk9Sl3jSrx5O)WmXKjnrMnr0Eotp7YDcB0EJjI0ez2eTs5Jjrurp7YDcB0EJjMUa3T6jlbUdTRW8YoHkyH9ejkWx5O)WeHiWTKth5CboApNPV325Woby0EJjI0eBXej9AzjbyueDfgSzE4rG83B7CYGDcWk7OJD9RPzyMyYKMiZMiApNPGouhHlZCny89dCLcP9gtePjQ(VsPGouhHlZCny89dCLcPRC0FyMy6cC3QNSe4V325ODcufQGfMQirb(kh9hMiebULC6iNlWv)xP09dCL6ph9DOsx5O)WmrKMylMiOVhQejOjMMjYuzIjMUa3T6jlb((bUs9NJ(oufQGf2Virb(kh9hMiebULC6iNlWv)xPuOkjGH3AgHUYr)HzIinXwmrIFy81ELsDmmi1k7LAIPzITYetM0ej(HXx7vk1XWG0RmreAIigtmX0nrKMylMiOVhQejOjMMjI4iUjMUa3T6jlbouLeWWBnJiublmfrIc8vo6pmricCl50roxGR(VsPZgiVcGddK2W0vo6pmtePjALYhtIOI(EBNJ2jqLsgOFf0etJHjcyXe4UvpzjWNnqEfahgiTHfQGLqzIirb(kh9hMiebULC6iNlWv)xP0zdKxbWHbsBy6kh9hMjI0er75mD2a5vaCyG0gM2Be4UvpzjWFVTZr7eOkublHgQirb(kh9hMiebULC6iNlWv)xP0)yx)W4GoaOZvPoq6kh9hMa3T6jlb(FSRFyCqha05QuhOqfSekcejkWx5O)WeHiWTKth5CboApNPZgihKlZCaYCLd7f2ixbq7nMistu9FLsbDOocxM5AW47h4kfsx5O)WmrKMiApNPGouhHlZCny89dCLcP9gbUB1twc85enGDDp8eQGLqBLirb(kh9hMiebULC6iNlWr75mfQscy4TMrO9gtePjI2ZzkOd1r4YmxdgF)axPqAVXerAIG(EOsKGMyAMi7XebUB1twc8)ac06kaoQ8vHkyjuexKOaFLJ(dteIa3soDKZf4O9CMoBGCqUmZbiZvoSxyJCfaT3yIinXwmr1)vkf0H6iCzMRbJVFGRuiDLJ(dZerAITyIO9CMc6qDeUmZ1GX3pWvkK2BmXKjnrRu(ysev03B7C0obQuYa9RGMicnrMyIinrqFpujsqteHmmrMccmXKjnryZ(NRobykKAd8R4)beO1vaMyAMicmrKMiApNPqvsadV1mcT3yIinrRu(ysev03B7C0obQuYa9RGMyAmmralMjMUjMmPjYSjQ(VsPGouhHlZCny89dCLcPRC0FyMyYKMOvkFmjIk6(bUs9NJ(ouPKb6xbnX0yyIWP6vaqkuDByoApNhXezAteWIzImTjIatmDbUB1twc85enGDDp8eQGLqrmrIc8vo6pmricCl50roxGdB2)C1jatHuBGFf)pGaTUcWerOjgQjI0ez2eXKkn)o44WaPnmLSmzWah9NjI0ez2ej9Azjby0zdKdYLzoazUYH9cBKRaOJD9RPzyMistSftKztu9FLsbDOocxM5AW47h4kfsx5O)WmXKjnr0EotbDOocxM5AW47h4kfs7nMyYKMOvkFmjIk67TDoANavkzG(vqteHMitmrKMiOVhQejOjIqgMitbbMy6cC3QNSe4ZjAa76E4jublHYEIef4RC0FyIqe4wYPJCUa3kLpMerfNm3QMistSftKzteTNZuqhQJWLzUgm((bUsH0EJjI0er75m9Sl3jSr7nMy6cC3QNSe4V325ODcufQGLqzQIef4RC0FyIqe4wYPJCUa3kLpMerfNm3QMist0g4eGbnreAIQ)Ru6SbsUmZ1GX3pWvkKUYr)HzIinrMnr0Eotp7YDcB0EJa3T6jlb(7TDoANavHkyju2Virb(kh9hMiebULC6iNlWv)xP0zdKCzMRbJVFGRuiDLJ(dZerAImBIO9CMc6qDeUmZ1GX3pWvkK2BmrKMiOVhQejOjIqgMiIXetePjYSjI2Zz6SbYb5YmhGmx5WEHnYva0EJa3T6jlb(7TDoANavHkyjuMIirb(kh9hMiebULC6iNlWBXej9Azjby0zdKdYLzoazUYH9cBKRaOJD9RPzyMyYKMiSz)ZvNamfsTb(v8)ac06katmntebMy6MistSftu9FLsbDOocxM5AW47h4kfsx5O)WmrKMiZMiApNPZgihKlZCaYCLd7f2ixbq7nMistSfteTNZuqhQJWLzUgm((bUsH0EJjMmPjc67HkrcAIiKHjYuqGjMmPjcB2)C1jatHuBGFf)pGaTUcWetZerGjI0er75mfQscy4TMrO9gtePjALYhtIOI(EBNJ2jqLsgOFf0etJHjcyXmX0nXKjnrMnr1)vkf0H6iCzMRbJVFGRuiDLJ(dZetM0eTs5Jjrur3pWvQ)C03HkLmq)kOjMgdteovVcasHQBdZr758iMitBIawmtKPnreyIPlWDREYsGpNObCyG0gwOcwqatejkWx5O)WeHiWTKth5CbU6)kLE2L7e2ORC0FyMistu9FLsbDOocxM5AW47h4kfsx5O)WmrKMiApNPND5oHnAVXerAIO9CMc6qDeUmZ1GX3pWvkK2Be4UvpzjWZeju5WaPnSqfSGGqfjkWx5O)WeHiWTKth5CboApNPo0UcZl7O9gbUB1twc83B7C0obQcvWccqGirb(kh9hMiebULC6iNlWTs5JjruXjZTQjI0ez2ev)xPuqhQJWLzUgm((bUsH0vo6pmbUB1twc83B7C0obQcvWccALirb(kh9hMiebULC6iNlWv)xP0ZUCNWgDLJ(dZerAImBITyIG(EOsKGMicnXwHyMist0kLpMerf992ohTtGkLmq)kOjMgdtKjMy6cC3QNSe4ND5oHnHkybbiUirb(kh9hMiebULC6iNlWv)xP0ZUCNWgDLJ(dZerAIO9CME2L7e2O9gtePj2IjI2Zz6zxUtyJsgOFf0etZebSyMitBIiUjY0MiApNPND5oHnkuDBytmzsteTNZuOkjGH3AgH2BmXKjnrMnr1)vkf0H6iCzMRbJVFGRuiDLJ(dZetxG7w9KLaptKqLddK2WcvWccqmrIcC3QNSe4V325ODcuf4RC0FyIqeQGfeWEIef4RC0FyIqe4UvpzjWZVdoomqAdlWTKth5CbozzYGbo6pbULn7pU6eGPqblHkubliGPksuGVYr)HjcrGBjNoY5cCsVwwsagD)axP(Zh763FOKRdsh76xtZWmrKMiZMiApNP7h4k1F(yx)(dLCDqo2q75mT3yIinrMnr1)vkD)axP(ZrFhQ0vo6pmtePjYSjQ(VsPZgiVcGddK2W0vo6pmbUB1twc8mrcvomqAdlubliG9lsuG7w9KLa3g4xXdCs7bvb(kh9hMieHkybbmfrIc8vo6pmricCl50roxGR(VsPND5oHn6kh9hMjI0er75m9Sl3jSr7ncC3QNSe4zIeQCyG0gwOcwAftejkWx5O)WeHiWTKth5CbU6)kLcvxplh7G2aNam6kh9hMa3T6jlbouD9SCSdAdCcWeQGLwfQirb(kh9hMiebULC6iNlWz2ev)xP0gYb6pF)axP(FqLUYr)HzIjtAImBIntP5Jm((bUs9N6w9ApbUB1twc85enGVFGRu)fQGLwHarIc8vo6pmricCl50roxGdB2)C1jatHuBGFf)pGaTUcWerOjgQa3T6jlbUnWVI)hqGwxbiublTQvIef4UvpzjW)diqRRa4OYxf4RC0FyIqeQGLwH4Ief4GY2xbiyjub(kh9hhu2(karicC3QNSe453bhhgiTHf4w2S)4QtaMcfSeQa3soDKZf4KLjdg4O)e4RC0FyIqeQGLwHyIef4RC0FyIqe4RC0FCqz7RaeHiWTKth5CboOS9axPuSdQEzNjIqtK9e4UvpzjWZVdoomqAdlWbLTVcqWsOcvWsRyprIcCqz7RaeSeQaFLJ(JdkBFfGiebUB1twc8mrcvomqAdlWx5O)WeHiublTIPksuGVYr)HjcrGBjNoY5cC1)vk9Sl3jSrx5O)WmrKMiApNPND5oHnAVXerAIO9CME2L7e2OKb6xbnX0mr4u9kaifQUnmhTNZJyImTjcyXmrM2er75m9Sl3jSrHQBdlWDREYsGNjsOYHbsByHkubo2YE)vrIcwcvKOaFLJ(dteIahBql5A0twcC2NshH0ButuMnrRdvivG7w9KLahrxHXHbZjcvWccejkWbLTVcqWsOc8vo6poOS9vaIqe4UvpzjWHnh5ue5F4rGCaIBNaFLJ(dteIqfS0krIcC3QNSe4ns9KLaFLJ(dteIqfSG4Ief4UvpzjW7WXpDGqb(kh9hMieHkybXejkWx5O)WeHiWTKth5CbElMiZMO6)kLUFGRu)5OVdv6kh9hMjMUjI0ez2e1Zg(katePjYSj2mLcvjbKVFGRu)PUvV2ZerAITyIWM9pxDcWui1g4xX)diqRRamX0mXwzIjtAIQ)RukOd1r4YmxdgF)axPq6kh9hMjMmPjs61YscWOWWSHsMhEeipFJWghBGhC0XU(10mmtmDbUB1twc887GJddK2WcvWc7jsuGVYr)HjcrG7w9KLaVHCGsc25phrE7jWTKth5CboZMiApNPnKdusWo)5iYBpAVXerAITyImBIntPqvsa57h4k1FQB1R9mXKjnryZ(NRobykKAd8R4)beO1vaMyAMyRmrKMiApNPi6kmoqhQuO62WMyAMicyIjMmPjcL9h9km6phJJYgFTooyZp6kh9hMjMUjI0eBXeHn7FU6eGPqQnWVI)hqGwxbyIPzIiMjMmPjQ(VsPGouhHlZCny89dCLcPRC0FyMyYKMiPxlljaJcdZgkzE4rG88ncBCSbEWrh76xtZWmXKjnrOS)OxHr)5yCu24R1XbB(rx5O)WmX0f4w2S)4QtaMcfSeQqfSWufjkWx5O)WeHiWTKth5CboZMOE2WxbyIinXwmrMnXMPuOkjG89dCL6p1T61EMyYKMiSz)ZvNamfsTb(v8)ac06katmntSvMisteTNZueDfghOdvkuDBytmntebmXet3erAITyIWM9pxDcWui1g4xX)diqRRamX0mXwzIjtAIQ)RukOd1r4YmxdgF)axPq6kh9hMjMmPjs61YscWOWWSHsMhEeipFJWghBGhC0XU(10mmtmDbUB1twc887GJddK2WcvWc7xKOa3T6jlbE(iJVFGRu)f4RC0FyIqeQGfMIirbUB1twcCWPtse4RC0FyIqeQGLqzIirb(kh9hMiebULC6iNlWz2ev)xPuhAxH5LD0vo6pmtmzsteTNZuhAxH5LD0EJjMmPjALYhtIOI6q7kmVSJsgOFf0erOjIymrG7w9KLah9LsmEUtytOcwcnurIc8vo6pmricCl50roxGZSjQ(VsPo0UcZl7ORC0FyMyYKMiApNPo0UcZl7O9gbUB1twcC0rGJe(kaHkyjueisuGVYr)HjcrGBjNoY5cCMnr1)vk1H2vyEzhDLJ(dZetM0er75m1H2vyEzhT3yIjtAIwP8XKiQOo0UcZl7OKb6xbnreAIigte4UvpzjWZhzOVuIjublH2krIc8vo6pmricCl50roxGZSjQ(VsPo0UcZl7ORC0FyMyYKMiApNPo0UcZl7O9gtmzst0kLpMerf1H2vyEzhLmq)kOjIqteXyIa3T6jlbUx2bvI)CR)VqfSekIlsuGVYr)HjcrGBjNoY5cCMnr1)vk1H2vyEzhDLJ(dZetM0ez2er75m1H2vyEzhT3iWDREYsGJ6aCzMRKZggkublHIyIef4UvpzjWBpyZiCvQduGVYr)HjcrOcwcL9ejkWx5O)WeHiWTKth5CbUv2ELxkToGaLN9zIinXwmrMnr1)vkf0H6iCzMRbJVFGRuiDLJ(dZetM0er75mf0H6iCzMRbJVFGRuiT3yIPBIinryZ(NRobykKAd8R4)beO1vaMyAMyRe4UvpzjWZ(4kXlyUdpzjublHYufjkWx5O)WeHiWTKth5CbUB1R94Rg4nOjIqtebMistSfte2S)5QtaMcP2a)k(FabADfGjIqtebMyYKMiSz)ZvNamfsFVTZrNdAIi0erGjMUa3T6jlboPxC3QNS4)bvb(FqLxo4e4UCcvWsOSFrIc8vo6pmricCl50roxGZSjQ(VsPqvsa57h4k1F6kh9hMjI0eDREThF1aVbnX0yyIiqGdvYzvblHkWDREYsGt6f3T6jl(FqvG)hu5Ldobo8kGFC1jatfQGLqzkIef4RC0FyIqe4wYPJCUax9FLsHQKaY3pWvQ)0vo6pmtePj6w9Ap(QbEdAIPXWerGahQKZQcwcvG7w9KLaN0lUB1tw8)GQa)pOYlhCcC44WRa(XvNamvOcvG3qMvcI6QirblHksuGVYr)HjcrG7w9KLaFord47h4k1Fbo2GwY1ONSe4TwToZ21HzIR9iSzI6botudMj6wvsmXdAIEB)Eh9hvGBjNoY5cCMnr1)vkTHCG(Z3pWvQ)huPRC0FycvWccejkWx5O)WeHiWDREYsGdvjbm8wZicCSbTKRrpzjWB9aNjIRscy4TMrmXgYSsquxnXE9dcnrOeCMOJHbnreD)BIWghrLjcLYIkWTKth5CbU6)kLcvjbm8wZi0vo6pmtePj2Ijs8dJV2RuQJHbPwzVutmntSvMyYKMiXpm(AVsPoggKELjIqteXyIjMUqfS0krIcC3QNSe45Jm((bUs9xGVYr)HjcrOcwqCrIc8vo6pmricCl50roxGR(VsP7h4k1Fo67qLUYr)HzIinryZ(NRobykKAd8R4)beO1vaMyAMyRe4UvpzjW3pWvQ)C03HQqfSGyIef4RC0FyIqe4UvpzjWFVTZr7eOkW)Rg3IjWBLa3soDKZf4mBIQ)Ru6(bUs9NJ(ouPRC0FyMiste2S)5QtaMcP2a)k(FabADfGjMMj2ktmzsteTNZuOkjGH3AgH2Be4ydAjxJEYsGhYSEhotK9v7qmXahAIUjQeV9EtupWLGjQbZeDmmzzInVBh0ezAn4GM4kLWgtBIYYeBDB9AIzjXeBLjcNvwyqtuLMO3wEyMiMSJ(R1M9v7qmrzzIn9)PcvWc7jsuGVYr)HjcrGBjNoY5cCMnr1)vkD)axP(ZrFhQ0vo6pmtePjcB2)C1jatHuBGFf)pGaTUcWeridtSvMistKzteTNZuOkjGH3AgH2Be4UvpzjWTb(v8)ac06kaHkyHPksuG7w9KLaVrQNSe4RC0FyIqeQqf4UCIefSeQirbUB1twcCOkjG89dCL6VaFLJ(dteIqfSGarIc8vo6pmricCl50roxGJ2ZzQ1)N)hqGwxbqjd0VcAIiKHjgkte4UvpzjWhBJlZCnyCOkjGcvWsRejkWx5O)WeHiWTKth5CboApNPZgiVcGddK2W0EJa3T6jlb(CIgWUUhEcvWcIlsuG7w9KLa3g4xXdCs7bvb(kh9hMieHkybXejkWx5O)WeHiWTKth5CbU6)kLcvjbm8wZi0vo6pmbUB1twcCOkjGH3AgrOcwyprIc8vo6pmricC3QNSe453bhhgiTHf4wYPJCUaNSmzWah9NjI0eBXeBXeDREThhtQ087GJddK2WMyAMicmrKMOB1R94Rg4nOjMgdtSvMist0kLpMerfTHCGsc25phrE7rjd0VcAIPzIHYEMist0kBVYlLwZsKVKGzIinrMnXMPuOkjG89dCL6p1T61EMyYKMOB1R94ysLMFhCCyG0g2etZed1erAIUvV2JVAG3GMiczyIiUjI0ez2eBMsHQKaY3pWvQ)u3Qx7zIinr1)vkf0H6iCzMRbJVFGRuiDLJ(dZet3etM0eBXej9Azjbyuyy2qjZdpcKNVryJJnWdo6yx)AAgMjI0ez2eBMsHQKaY3pWvQ)u3Qx7zIPBIPlWTSz)XvNamfkyjuHkyHPksuGVYr)HjcrGBjNoY5cCMnr3Qx7XXKkn)o44WaPnSjI0ez2eBMsHQKaY3pWvQ)u3Qx7zIinXwmr1)vkf0H6iCzMRbJVFGRuiDLJ(dZetM0ej9Azjbyuyy2qjZdpcKNVryJJnWdo6yx)AAgMjMUa3T6jlbE(DWXHbsByHkyH9lsuGVYr)HjcrGBjNoY5cC1)vkD2a5vaCyG0gMUYr)HzIinrqFpujsqteHmmr2JjMistSftK0RLLeGrNnqoixM5aK5kh2lSrUcGo21VMMHzIinr0EotNnqoixM5aK5kh2lSrUcG2BmXKjnrMnrsVwwsagD2a5GCzMdqMRCyVWg5ka6yx)AAgMjMUa3T6jlb(SbYRa4WaPnSqfSWuejkWx5O)WeHiWTKth5CbU6)kL6q7kmVSJUYr)HzIinXwmrMnXMPuOkjG89dCL6p1T61EMy6MistSftKztu9FLsp7YDcB0vo6pmtmzstKzteTNZ0ZUCNWgT3yIinrMnrRu(ysev0ZUCNWgT3yIPlWDREYsG7q7kmVStOcwcLjIef4RC0FyIqe4wYPJCUax9FLs)JD9dJd6aGoxL6aPRC0FycC3QNSe4)XU(HXbDaqNRsDGcvWsOHksuGVYr)HjcrGBjNoY5cCyZ(NRobykKAd8R4)beO1vaMyAMiIBIinr0EotbDOocxM5AW47h4kfs7nMiste03dvIe0etZermMiWDREYsGBd8R4)beO1vacvWsOiqKOaFLJ(dteIa3soDKZf4KETSKam6SbYb5YmhGmx5WEHnYva0XU(10mmtePjYSjI2Zz6SbYb5YmhGmx5WEHnYva0EJa3T6jlb(CIgWHbsByHkyj0wjsuGVYr)HjcrGBjNoY5cCmPsZVdoomqAdtjd0VcAIinryZ(NRobykKAd8R4)beO1vaMyAMiIBIinXwmrMnXMPuOkjG89dCL6p1T61EMy6MistSfteTNZ03B7CyNamAVXerAImBIO9CMc6qDeUmZ1GX3pWvkK2BmrKMO6)kLc6qDeUmZ1GX3pWvkKUYr)HzIPlWDREYsG)EBNJ2jqvOcwcfXfjkWx5O)WeHiWTKth5CboSz)ZvNamfsTb(v8)ac06kateHmmreyIinrMnrsVwwsagD2a5GCzMdqMRCyVWg5ka6yx)AAgMjI0eBXev)xPuqhQJWLzUgm((bUsH0vo6pmtePjc67HkrcAIiKHjIymXerAImBIO9CMc6qDeUmZ1GX3pWvkK2BmX0f4UvpzjWNt0a219WtOcwcfXejkWx5O)WeHiWTKth5CboMuP53bhhgiTHPKb6xbnrKMiApNPV325Woby0EJjI0er75mTHCGsc25phrE7r7ncC3QNSe4V325ODcufQGLqzprIc8vo6pmricCl50roxGJjvA(DWXHbsBykzG(vqtePjcB2)C1jatHuBGFf)pGaTUcWetZerCtePjs61YscWOWWSHsMhEeipFJWghBGhC0XU(10mmtePjI2Zz67TDoStagT3yIinr1)vkf0H6iCzMRbJVFGRuiDLJ(dZerAImBIO9CMc6qDeUmZ1GX3pWvkK2BmrKMiOVhQejOjIqgMiIXebUB1twc83B7C0obQcvWsOmvrIc8vo6pmricCl50roxGJjvA(DWXHbsBykzG(vqtePj2Ij2IjcB2)C1jatHuBGFf)pGaTUcWetZerCtePjs61YscWOWWSHsMhEeipFJWghBGhC0XU(10mmtePjQ(VsPGouhHlZCny89dCLcPRC0FyMy6MyYKMylMO6)kLc6qDeUmZ1GX3pWvkKUYr)HzIinrqFpujsqteHmmreJjMistKzteTNZuqhQJWLzUgm((bUsH0EJjI0eBXez2ej9Azjby0zdKdYLzoazUYH9cBKRaOJD9RPzyMyYKMiApNPZgihKlZCaYCLd7f2ixbq7nMy6MistKztK0RLLeGrHHzdLmp8iqE(gHno2ap4OJD9RPzyMy6My6cC3QNSe4V325ODcufQGLqz)Ief4RC0FyIqe4wYPJCUahtQ087GJddK2WuYa9RGMiste2S)5QtaMcP2a)k(FabADfGjYWerCtePjs61YscWOWWSHsMhEeipFJWghBGhC0XU(10mmtePjI2Zz67TDoStagT3yIinr1)vkf0H6iCzMRbJVFGRuiDLJ(dZerAImBIO9CMc6qDeUmZ1GX3pWvkK2BmrKMiOVhQejOjIqgMiIXebUB1twc83B7C0obQcvWsOmfrIc8vo6pmricCl50roxGdB2)C1jatHuBGFf)pGaTUcWeridtebcC3QNSe4ZjAa76E4jubliGjIef4RC0FyIqe4wYPJCUahTNZuOkjGH3AgHsgOFf0etZeBLjY0MiGfZezAteTNZuOkjGH3AgHcv3gwG7w9KLa3g4xX)diqRRaeQGfeeQirb(kh9hMiebULC6iNlWr75m992oh2jaJ2BmrKMiSz)ZvNamfsTb(v8)ac06katmnteXnrKMylMiZMyZukuLeq((bUs9N6w9AptmDtePjIjvA(DWXHbsByQE2WxbiWDREYsG)EBNJ2jqvOcwqacejkWx5O)WeHiWTKth5CbU6)kLUFGRu)5OVdv6kh9hMjI0eHn7FU6eGPqQnWVI)hqGwxbyIPzIiMjI0eBXez2eBMsHQKaY3pWvQ)u3Qx7zIPlWDREYsGVFGRu)5OVdvHkybbTsKOaFLJ(dteIa3soDKZf4Q)RuQdTRW8Yo6kh9hMa3T6jlb(7TDo6CqHkybbiUirbUB1twcCBGFf)pGaTUcqGVYr)HjcrOcwqaIjsuGVYr)HjcrGVYr)XbLTVcqeIa3soDKZf4O9CM(EBNd7eGr7nMist0kLpMerfNm3QcC3QNSe4V325ODcuf4GY2xbiyjuHkybbSNirboOS9vacwcvGVYr)XbLTVcqeIa3T6jlbE(DWXHbsBybULn7pU6eGPqblHkWTKth5CbozzYGbo6pb(kh9hMieHkybbmvrIcCqz7RaeSeQaFLJ(JdkBFfGiebUB1twc8mrcvomqAdlWx5O)WeHiuHkWHJdVc4hxDcWurIcwcvKOa3T6jlbouLeq((bUs9xGVYr)HjcrOcwqGirb(kh9hMiebULC6iNlWr75m16)Z)diqRRaOKb6xbnreYWedLjcC3QNSe4JTXLzUgmouLeqHkyPvIef4RC0FyIqe4wYPJCUax9FLsp7YDcB0vo6pmtePjI2Zz6zxUtyJ2BmrKMiApNPND5oHnkzG(vqtmnteovVcasHQBdZr758iMitBIawmtKPnr0Eotp7YDcBuO62WMisteTNZueDfghOdvkuDBytmntmu2Va3T6jlbEMiHkhgiTHfQGfexKOaFLJ(dteIa3soDKZf4Q)Ru6(bUs9NJ(ouPRC0FycC3QNSe47h4k1Fo67qvOcwqmrIc8vo6pmricCl50roxGR(VsPqvsadV1mcDLJ(dtG7w9KLahQscy4TMreQGf2tKOaFLJ(dteIa3soDKZf4Q)Ru6SbYRa4WaPnmDLJ(dZerAIwP8XKiQOV325ODcuPKb6xbnX0yyIawmtePjcB2)C1jatHuBGFf)pGaTUcWetZerGjMmPjc67HkrcAIiKHjYEmXerAIWM9pxDcWui1g4xX)diqRRamreYWerGjI0eBXez2ej9Azjby0zdKdYLzoazUYH9cBKRaOJD9RPzyMyYKMiApNPZgihKlZCaYCLd7f2ixbq7nMy6MyYKMiSz)ZvNamfsTb(v8)ac06katmntebMisteTNZueDfghOdvkuDByteHmmXqz)MistSftKztK0RLLeGrNnqoixM5aK5kh2lSrUcGo21VMMHzIjtAIO9CMoBGCqUmZbiZvoSxyJCfaT3yIPBIinrqFpujsqteHmmr2JjcC3QNSe4ZgiVcGddK2WcvWctvKOaFLJ(dteIa3soDKZf4TyIO9CMIORW4aDOsHQBdBIPzIHY(nrKMiZMiApNPOVuI9DOs7nMy6MyYKMiApNPV325Woby0EJa3T6jlb(7TDoANavHkyH9lsuGVYr)HjcrGBjNoY5cC1)vkD2a5vaCyG0gMUYr)HzIinr0EotNnqEfahgiTHP9gtePjcB2)C1jatHuBGFf)pGaTUcWetZerGa3T6jlb(7TDoANavHkyHPisuGVYr)HjcrGBjNoY5cC1)vkD2a5vaCyG0gMUYr)HzIinr0EotNnqEfahgiTHP9gtePjcB2)C1jatHuBGFf)pGaTUcWeridtebcC3QNSe4ZjAa76E4jublHYerIc8vo6pmricCl50roxGJ2ZzkuLeWWBnJq7ncC3QNSe4)beO1vaCu5RcvWsOHksuGVYr)HjcrGBjNoY5cC0EotNnqoixM5aK5kh2lSrUcG2Be4UvpzjWNt0a219WtOcwcfbIef4RC0FyIqe4wYPJCUah2S)5QtaMcP2a)k(FabADfGjMMjIatePjc67HkrcAIiKHjYEmXerAITyIO9CMIORW4aDOsHQBdBIPzIiGjMyYKMiOVhQejOjIqtKPWetmDtmzstSftK0RLLeGrNnqoixM5aK5kh2lSrUcGo21VMMHzIinrMnr0EotNnqoixM5aK5kh2lSrUcG2BmX0f4UvpzjWNt0aomqAdlublH2krIc8vo6pmricCl50roxG3IjcB2)C1jatHuBGFf)pGaTUcWerOjgQjMUjI0eBXez2eXKkn)o44WaPnmLSmzWah9NjMUa3T6jlb(CIgWUUhEcvWsOiUirb(kh9hMiebULC6iNlWDREThF1aVbnreAIHAIinXMPuOkjG89dCL6p1T61EMisteTNZu0xkX(ouP9gbUB1twcCBGFf)pGaTUcqOcwcfXejkWx5O)WeHiWTKth5CbEZukuLeq((bUs9N6w9AptePjI2Zzk6lLyFhQ0EJa3T6jlb(FabADfahv(QqfSek7jsuGVYr)HjcrGBjNoY5cC0EotDODfMx2r7ncC3QNSe4V325ODcufQGLqzQIef4RC0FyIqe4wYPJCUa3kLpMerfNm3QcC3QNSe4V325ODcufQGLqz)Ief4RC0FyIqe4wYPJCUa3kLpMerfNm3QMist0g4eGbnreAIQ)Ru6SbsUmZ1GX3pWvkKUYr)HjWDREYsG)EBNJ2jqvOcwcLPisuGVYr)HjcrGBjNoY5cC1)vk9Sl3jSrx5O)WmrKMiApNPND5oHnAVrG7w9KLaptKqLddK2WcvWccyIirbUB1twcCBGFfpWjThuf4RC0FyIqeQGfeeQirb(kh9hMiebULC6iNlWv)xPuO66z5yh0g4eGrx5O)We4UvpzjWHQRNLJDqBGtaMqfSGaeisuGVYr)HjcrGBjNoY5cCMnr1)vkTHCG(Z3pWvQ)huPRC0FyMyYKMO6)kL2qoq)57h4k1)dQ0vo6pmtePj2IjYSj2mLcvjbKVFGRu)PUvV2ZetxG7w9KLaFord47h4k1FHkybbTsKOaFLJ(dteIa3soDKZf4UvV2JVAG3GMicnXqnrKMylMiSz)ZvNamfsTb(v8)ac06kateHMyOMyYKMiSz)ZvNamfsFVTZrNdAIi0ed1etxG7w9KLa3g4xX)diqRRaeQGfeG4Ief4UvpzjW)diqRRa4OYxf4RC0FyIqeQGfeGyIef4GY2xbiyjub(kh9hhu2(karicC3QNSe453bhhgiTHf4w2S)4QtaMcfSeQa3soDKZf4KLjdg4O)e4RC0FyIqeQGfeWEIef4RC0FyIqe4RC0FCqz7RaeHiWTKth5CboOS9axPuSdQEzNjIqtK9e4UvpzjWZVdoomqAdlWbLTVcqWsOcvWccyQIef4GY2xbiyjub(kh9hhu2(karicC3QNSe4zIeQCyG0gwGVYr)HjcrOcvOcvOcb]] )

end
