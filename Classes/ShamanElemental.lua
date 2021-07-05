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

    spec:RegisterPack( "Elemental", 20210705, [[diKeacqiuPEeekSjiAuIuDkrkRcvv8krsZseCliuu7cPFjsmmujoMG0YKs6zqatdcvxdc02qvv(gQQKXHQQY5qvLADOQQQMNuI7Hk2he0bHqPYcfepecL0eHqP0fHqrojQQQSsuLMjQQQYnHqPQDIQ4PiAQIqxfcLI9s0FrzWcDyQwmKEmLMmcxwzZI6ZQYOf40Q8Ab1SbUTQA3s(nHHlfhhvslhQNdA6KUUuTDPuFhcz8qOeNhvL5lI2pfldvMOKKW1j5PvU0AOCHFXfeKYf(hcYFiicijv(AMKSXTH93KKL)NKeXey)vQdKKnoFaHtituscfDSDsYavBG8)tjL3PbDuQv8tbE)oW1tuwSN1uG33MIKeTFaL)RKOsscxNKNw5sRHYf(fxqqkx4Fii)HGssyZSsEAL)AvsgCeeRKOssIbTssetG9xPoWejd8VxgE5Td4Zer8emXw5sRHA41WlI1aVEdY)3WlIztK)RScCJa76mr4u9QhKcv3gMH2Z5HnXSaBI8F2L7y(sWejvb(hERzyQHxeZMiIDeeMiI9tNaBIEryIiM4BMOiBIAWmrsvG)MO)8ROsYgSiFGjjrmqmmretG9xPoWejd8VxgErmqmmrE7a(mrepbtSvU0AOgEn8IyGyyIiwd86ni)FdVigigMiIztK)RScCJa76mr4u9QhKcv3gMH2Z5HnXSaBI8F2L7y(sWejvb(hERzyQHxededteXSjIyhbHjIy)0jWMOxeMiIj(MjkYMOgmtKuf4Vj6p)kQHxdVigMiIjelZ21ryIR9W8zI69NjQbZeDRkWM4bnrVTFahfmQHx3QNOG0g8SIpQRCMJ1a2a7VsDqcxMd3QdwP0g89DaBG9xPo4GkDLJcgHHxedteXg4mrsvG)H3Ag2eBWZk(OUAI9cmi0eHI)mrNGaAIi6aate24iQmrOquudVUvprbPn4zfFuxtLtkqvG)H3AgoHlZrDWkLcvb(hERzy6khfmcKPJ9JGT2RuQtqaPwrV0wqGKjX(rWw7vk1jiG0RqicYL0m86w9efK2GNv8rDnvoPKp8ydS)k1bgEDREIcsBWZk(OUMkNugy)vQdyOahQjCzoQdwP0b2FL6agkWHkDLJcgbsyZaaM643ui1g4xXa3lqRRETGagErmmXqM17WzI8)AhIjg4qt0nrf7ThWe17VemrnyMOtqiktSb42bnr(rdoOjUsX8XpMOOmreRi2AIzb2erateoROiGMOkmrVT4imrcrhfmeZ8)AhIjkktSPdaudVUvprbPn4zfFuxtLtkaVTZq7yOMa4QXSeCqGeUmhUvhSsPdS)k1bmuGdv6khfmcKWMbam1XVPqQnWVIbUxGwx9AbbsMeTNZuOkW)WBndt7ngEDREIcsBWZk(OUMkNuSb(vmW9c06QxcxMd3QdwP0b2FL6agkWHkDLJcgbsyZaaM643ui1g4xXa3lqRREiKdcGKB0EotHQa)dV1mmT3y41T6jkiTbpR4J6AQCsPrONOm8A4fXWe5)kDyCVrnrr2eTouHudVUvprbtLtki6kcgmyo2WRB1tuWu5KcS5WNIiheEyi7HD7s4lAF1JtOgEDREIcMkNuAe6jkdVUvprbtLtkD4yNUp0WRB1tuWu5Ksg4)XGbcB4eUmN05wDWkLoW(RuhWqbouPRCuWisdj36zdF1dj3ntPqvG)Sb2FL6aQB1R9qMoSzaatD8BkKAd8RyG7fO1vVwqGKjvhSsPFhQdZezMgm2a7VsH0vokyejtI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJindVUvprbtLtkn47lWeNdyiYBVeS8zbJPo(nfYj0eUmhUr75mTbFFbM4CadrE7r7nitN7MPuOkWF2a7VsDa1T61EjtcBgaWuh)McP2a)kg4EbAD1RfeajApNPi6kc2RdvkuDB4wALljtcfDa6veuWCcgkFSHyX)nGrx5OGrKgY0HndayQJFtHuBGFfdCVaTU61ccMmP6Gvk97qDyMiZ0GXgy)vkKUYrbJizsCVwwGFJcdZhkEE4HHS8nmFmI9p4OJR9RPzejtcfDa6veuWCcgkFSHyX)nGrx5OGrKMHx3QNOGPYjLmW)Jbde2WjCzoCRNn8vpKPZDZukuf4pBG9xPoG6w9AVKjHndayQJFtHuBGFfdCVaTU61ccGeTNZueDfb71HkfQUnClTYL0qMoSzaatD8BkKAd8RyG7fO1vVwqGKjvhSsPFhQdZezMgm2a7VsH0vokyejtI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJindVUvprbtLtk5dp2a7VsDGHx3QNOGPYjL)0jWgEDREIcMkNuqbcbbl3X8LWL5WT6Gvk1H2veEzhDLJcgrYKO9CM6q7kcVSJ2BsM0keacbIkQdTRi8YokEF)kicrqUy41T6jkyQCsbDy4WHV6LWL5WT6Gvk1H2veEzhDLJcgrYKO9CM6q7kcVSJ2Bm86w9efmvoPKp8qbcbrcxMd3QdwPuhAxr4LD0vokyejtI2ZzQdTRi8YoAVjzsRqaieiQOo0UIWl7O499RGieb5IHx3QNOGPYjfVSdQyhWSoaKWL5WT6Gvk1H2veEzhDLJcgrYKO9CM6q7kcVSJ2BsM0keacbIkQdTRi8YokEF)kicrqUy41T6jkyQCsb1FmrMP4ZggMWL5WT6Gvk1H2veEzhDLJcgrYKCJ2ZzQdTRi8YoAVXWRB1tuWu5Ks7bBgMPcDFdVUvprbtLtkzFmf7fm3HNOs4YCSI2R8sP19cuw2hsUX9Azb(nkCJaYezg2)nEPShwGinGoU2VMMrGmDUvhSsPFhQdZezMgm2a7VsH0vokyejtI2Zz63H6WmrMPbJnW(RuiT3KgsyZaaM643ui1g4xXa3lqRRETGagEDREIcMkNuY(yk2lyUdprLWL5yfTx5LsR7fOSSpK4ETSa)gfUrazImd7)gVu2dlqKgqhx7xtZiqMo3QdwP0Vd1HzImtdgBG9xPq6khfmIKjr75m97qDyMiZ0GXgy)vkK2BsMe2maGPo(nfsTb(vmW9c06Qhc5GaPHmDRqaieiQO5dp2a7VsDafVVFfeHTYLKjTcbGqGOIcvb(Zgy)vQdO499RGiSvUKMHx3QNOGPYjfCVyUvprXahutO8)44ILWL54w9Ap2Q9VbryRith2maGPo(nfsTb(vmW9c06QhcBnzsyZaaM643uif4TDg68pcBnndVUvprbtLtk4EXCREIIboOMq5)XbE1dmM6430eGk(SkNqt4YC4wDWkLcvb(Zgy)vQdORCuWiq6w9Ap2Q9VbBHtRgEDREIcMkNuW9I5w9efdCqnHY)JdCm4vpWyQJFttaQ4ZQCcnHlZrDWkLcvb(Zgy)vQdORCuWiq6w9Ap2Q9VbBHtRgEn86w9efK6IXbQc8NnW(Ruhy41T6jki1flvoPm(gtKzAWyqvG)jCzoO9CMADaGbUxGwx9O499RGiKtOCXWRB1tuqQlwQCszowd4A3dVeUmh0EotNnqC1Jbde2W0EJHx3QNOGuxSu5KInWVIf442dQgEDREIcsDXsLtkqvG)H3AgoHlZrDWkLcvb(hERzy6khfmcdVUvprbPUyPYjLmW)Jbde2Wjy5ZcgtD8BkKtOjCzo4LXdg4OGHm90DREThJqO0mW)Jbde2WT0ks3Qx7XwT)nylCqaKwHaqiqurBW3xGjohWqK3Eu8((vWwcL)qAfTx5LsRzXcGatGK7MPuOkWF2a7VsDa1T61Ejt6w9ApgHqPzG)hdgiSHBjuKUvV2JTA)BqeYbXrYDZukuf4pBG9xPoG6w9ApKQdwP0Vd1HzImtdgBG9xPq6khfmI0sMmDCVwwGFJcdZhkEE4HHS8nmFmI9p4OJR9RPzei5UzkfQc8NnW(RuhqDRETxAPz41T6jki1flvoPKb(FmyGWgoHlZHB3Qx7Xieknd8)yWaHnmsUBMsHQa)zdS)k1bu3Qx7HmD1bRu63H6WmrMPbJnW(RuiDLJcgrYK4ETSa)gfgMpu88Wddz5By(ye7FWrhx7xtZisZWRB1tuqQlwQCsz2aXvpgmqydNWL5OoyLsNnqC1Jbde2W0vokyei)(aqfl(iKd)XfKPJ71Yc8B0zdedYez2dpxzWErm8vp64A)AAgbs0EotNnqmitKzp8CLb7fXWx9O9MKj5g3RLf43OZgigKjYShEUYG9Iy4RE0X1(10mI0m86w9efK6ILkNuCODfHx2LWL5OoyLsDODfHx2rx5OGrGmDUBMsHQa)zdS)k1bu3Qx7LgY05wDWkLE2L7y(ORCuWisMKB0Eotp7YDmF0EdsUTcbGqGOIE2L7y(O9M0m86w9efK6ILkNuahx7hb77VVZuHUFcxMJ6GvkfCCTFeSV)(otf6(0vokyegEDREIcsDXsLtk2a)kg4EbAD1lHlZb2maGPo(nfsTb(vmW9c06Qxlios0Eot)ouhMjYmnySb2FLcP9gKFFaOIf)wqqUy41T6jki1flvoPmhRbmyGWgoHlZb3RLf43OZgigKjYShEUYG9Iy4RE0X1(10mcKCJ2Zz6SbIbzIm7HNRmyVig(QhT3y41T6jki1flvoPa82odTJHAcxMdHqPzG)hdgiSHP499RGiHndayQJFtHuBGFfdCVaTU61cIJmDUBMsHQa)zdS)k1bu3Qx7LgY0r75mf4TDgSJFJ2BqYnApNPFhQdZezMgm2a7VsH0Eds1bRu63H6WmrMPbJnW(RuiDLJcgrAgEDREIcsDXsLtkZXAax7E4LWL5aBgaWuh)McP2a)kg4EbAD1dHCAfj34ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMrGmD1bRu63H6WmrMPbJnW(RuiDLJcgbYVpauXIpc5GGCbj3O9CM(DOomtKzAWydS)kfs7nPz41T6jki1flvoPa82odTJHAcxMdHqPzG)hdgiSHP499RGir75mf4TDgSJFJ2BqI2ZzAd((cmX5agI82J2Bm86w9efK6ILkNuaEBNH2XqnHlZHqO0mW)Jbde2Wu8((vqKWMbam1XVPqQnWVIbUxGwx9AbXrI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJajApNPaVTZGD8B0Eds1bRu63H6WmrMPbJnW(RuiDLJcgbsUr75m97qDyMiZ0GXgy)vkK2Bq(9bGkw8riheKlgEDREIcsDXsLtkaVTZq7yOMWL5qiuAg4)XGbcBykEF)kiY0th2maGPo(nfsTb(vmW9c06QxliosCVwwGFJcdZhkEE4HHS8nmFmI9p4OJR9RPzeivhSsPFhQdZezMgm2a7VsH0vokyePLmz6QdwP0Vd1HzImtdgBG9xPq6khfmcKFFaOIfFeYbb5csUr75m97qDyMiZ0GXgy)vkK2BqMo34ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMrKmjApNPZgigKjYShEUYG9Iy4RE0EtAi5g3RLf43OWW8HINhEyilFdZhJy)do64A)AAgrAPz41T6jki1flvoPa82odTJHAcxMdHqPzG)hdgiSHP499RGiHndayQJFtHuBGFfdCVaTU6XbXrI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJajApNPaVTZGD8B0Eds1bRu63H6WmrMPbJnW(RuiDLJcgbsUr75m97qDyMiZ0GXgy)vkK2Bq(9bGkw8riheKlgEDREIcsDXsLtkZXAax7E4LWL5aBgaWuh)McP2a)kg4EbAD1dHCA1WRB1tuqQlwQCsXg4xXa3lqRREjCzoO9CMcvb(hERzykEF)kylia)8Se8dApNPqvG)H3AgMcv3g2WRB1tuqQlwQCsb4TDgAhd1eUmh0EotbEBNb743O9gKWMbam1XVPqQnWVIbUxGwx9AbXrMo3ntPqvG)Sb2FL6aQB1R9sdjHqPzG)hdgiSHP6zdF1ZWRB1tuqQlwQCszG9xPoGHcCOMWL5OoyLshy)vQdyOahQ0vokyeiHndayQJFtHuBGFfdCVaTU61ccImDUBMsHQa)zdS)k1bu3Qx7LMHx3QNOGuxSu5KcWB7m05)eUmh1bRuQdTRi8Yo6khfmcdVUvprbPUyPYjfBGFfdCVaTU6z41T6jki1flvoPa82odTJHAcFr7RECcnHlZbTNZuG32zWo(nAVbPviaecevm8CRA41T6jki1flvoPKb(FmyGWgoHVO9vpoHMGLplym1XVPqoHMWL5GxgpyGJcMHx3QNOGuxSu5KsglGkdgiSHt4lAF1JtOgEn86w9efKchdE1dmM643uoqvG)Sb2FL6adVUvprbPWXGx9aJPo(nnvoPm(gtKzAWyqvG)jCzoO9CMADaGbUxGwx9O499RGiKtOCXWRB1tuqkCm4vpWyQJFttLtkzSaQmyGWgoHlZrDWkLE2L7y(ORCuWiqI2Zz6zxUJ5J2BqI2Zz6zxUJ5JI33Vc2cCQE1dsHQBdZq758W8ZZsWpO9CME2L7y(Oq1THrI2ZzkIUIG96qLcv3gULq5FgEDREIcsHJbV6bgtD8BAQCszG9xPoGHcCOMWL5OoyLshy)vQdyOahQ0vokyegEDREIcsHJbV6bgtD8BAQCsbQc8p8wZWjCzoQdwPuOkW)WBndtx5OGry41T6jkifog8Qhym1XVPPYjLzdex9yWaHnCcxMJ6GvkD2aXvpgmqydtx5OGrG0keacbIkkWB7m0ogQu8((vWw48SeiHndayQJFtHuBGFfdCVaTU61sRjt(9bGkw8rih(JliHndayQJFtHuBGFfdCVaTU6HqoTImDUX9Azb(n6SbIbzIm7HNRmyVig(QhDCTFnnJizs0EotNnqmitKzp8CLb7fXWx9O9M0sMe2maGPo(nfsTb(vmW9c06QxlTIeTNZueDfb71HkfQUnmc5ek)dz6CJ71Yc8B0zdedYez2dpxzWErm8vp64A)AAgrYKO9CMoBGyqMiZE45kd2lIHV6r7nPH87davS4Jqo8hxm86w9efKchdE1dmM6430u5KcWB7m0ogQjCzoPJ2ZzkIUIG96qLcv3gULq5Fi5gTNZuuGqqa6qL2Bslzs0EotbEBNb743O9gdVUvprbPWXGx9aJPo(nnvoPa82odTJHAcxMJ6GvkD2aXvpgmqydtx5OGrGeTNZ0zdex9yWaHnmT3Ge2maGPo(nfsTb(vmW9c06QxlTA41T6jkifog8Qhym1XVPPYjL5ynGRDp8s4YCuhSsPZgiU6XGbcBy6khfmcKO9CMoBG4QhdgiSHP9gKWMbam1XVPqQnWVIbUxGwx9qiNwn86w9efKchdE1dmM6430u5Kc4EbAD1JHkaAcxMdApNPqvG)H3AgM2Bm86w9efKchdE1dmM6430u5KYCSgW1UhEjCzoO9CMoBGyqMiZE45kd2lIHV6r7ngEDREIcsHJbV6bgtD8BAQCszowdyWaHnCcxMdSzaatD8BkKAd8RyG7fO1vVwAf53haQyXhHC4pUGmD0Eotr0veSxhQuO62WT0kxsM87davS4Jq(nxslzY0X9Azb(n6SbIbzIm7HNRmyVig(QhDCTFnnJaj3O9CMoBGyqMiZE45kd2lIHV6r7nPz41T6jkifog8Qhym1XVPPYjL5ynGRDp8s4YCsh2maGPo(nfsTb(vmW9c06QhcdnnKPZnHqPzG)hdgiSHP4LXdg4OGLMHx3QNOGu4yWREGXuh)MMkNuSb(vmW9c06QxcxMJB1R9yR2)geHHISzkfQc8NnW(RuhqDREThs0EotrbcbbOdvAVXWRB1tuqkCm4vpWyQJFttLtkG7fO1vpgQaOjCzontPqvG)Sb2FL6aQB1R9qI2ZzkkqiiaDOs7ngEDREIcsHJbV6bgtD8BAQCsb4TDgAhd1eUmh0EotDODfHx2r7ngEDREIcsHJbV6bgtD8BAQCsb4TDgAhd1eUmhRqaieiQy45w1WRB1tuqkCm4vpWyQJFttLtkaVTZq7yOMWL5yfcaHarfdp3QiTbo(nicvhSsPZgiyImtdgBG9xPq6khfmcdVUvprbPWXGx9aJPo(nnvoPKXcOYGbcB4eUmh1bRu6zxUJ5JUYrbJajApNPND5oMpAVXWRB1tuqkCm4vpWyQJFttLtk2a)kwGJBpOA41T6jkifog8Qhym1XVPPYjfO66zzeh0g443s4YCuhSsPq11ZYioOnWXVrx5OGry41T6jkifog8Qhym1XVPPYjL5ynGnW(RuhKWL5WT6GvkTbFFhWgy)vQdoOsx5OGrKmP6GvkTbFFhWgy)vQdoOsx5OGrGmDUBMsHQa)zdS)k1bu3Qx7LMHx3QNOGu4yWREGXuh)MMkNuSb(vmW9c06QxcxMJB1R9yR2)geHHImDyZaaM643ui1g4xXa3lqRREim0KjHndayQJFtHuG32zOZ)im00m86w9efKchdE1dmM6430u5Kc4EbAD1JHkaQHx3QNOGu4yWREGXuh)MMkNuYa)pgmqydNWx0(QhNqtWYNfmM643uiNqt4YCWlJhmWrbZWRB1tuqkCm4vpWyQJFttLtkzG)hdgiSHt4lAF1JtOjCzoFr79xPuIdQEzhc5pdVUvprbPWXGx9aJPo(nnvoPKXcOYGbcB4e(I2x94eQHxdVUvprbPWREGXuh)MYbCVaTU6XqfanHlZjD0EotHQa)dV1mmfVVFfSf4u9QhKcv3gMH2Z5H5NNLGFq75mfQc8p8wZWuO62WPz41T6jkifE1dmM6430u5KsglGkdgiSHt4YCuhSsPND5oMp6khfmcKO9CME2L7y(O9gKO9CME2L7y(O499RGTaNQx9GuO62Wm0Eopm)8Se8dApNPND5oMpkuDBydVUvprbPWREGXuh)MMkNuYa)pgmqydNGLplym1XVPqoHMWL5Ko36zdF1lzscHsZa)pgmqydtX77xbBHZZsKmP6Gvk1H2veEzhDLJcgbscHsZa)pgmqydtX77xbBjDRqaieiQOo0UIWl7O499RGPI2ZzQdTRi8Yokrh76jQ0qAfcaHarf1H2veEzhfVVFfSfepnKPJ2ZzkWB7myh)gT3Kmj3O9CMIceccqhQ0EtAgEDREIcsHx9aJPo(nnvoPKb(FmyGWgoblFwWyQJFtHCcnHlZbTNZ0g89fyIZbme5ThT3GeVmEWahfmdVUvprbPWREGXuh)MMkNuCODfHx2LWL5OoyLsDODfHx2rx5OGrGmD9(dHC4pUKmjApNPOaHGa0HkT3KgY0TcbGqGOIc82odTJHkfVVFfeHCjnKPZT6Gvk9Sl3X8rx5OGrKmj3O9CME2L7y(O9gKCBfcaHarf9Sl3X8r7nPz41T6jkifE1dmM6430u5KcWB7m0ogQjCzoO9CMc82od2XVr7nith3RLf43Oi6kcyZ8WddzaVTZWd2XVv2rhx7xtZisMKB0Eot)ouhMjYmnySb2FLcP9gKQdwP0Vd1HzImtdgBG9xPq6khfmI0m86w9efKcV6bgtD8BAQCszG9xPoGHcCOMWL5OoyLshy)vQdyOahQ0vokyeit)7davS43c)IlPz41T6jkifE1dmM6430u5Kcuf4F4TMHt4YCuhSsPqvG)H3AgMUYrbJaz6y)iyR9kL6eeqQv0lTfeizsSFeS1ELsDcci9keIGCjnKP)9bGkw8BbXr80m86w9efKcV6bgtD8BAQCsz2aXvpgmqydNWL5OoyLsNnqC1Jbde2W0vokyeiTcbGqGOIc82odTJHkfVVFfSfoplHHx3QNOGu4vpWyQJFttLtkaVTZq7yOMWL5OoyLsNnqC1Jbde2W0vokyeir75mD2aXvpgmqydt7ngEDREIcsHx9aJPo(nnvoPaoU2pc23FFNPcD)eUmh1bRuk44A)iyF)9DMk09PRCuWim86w9efKcV6bgtD8BAQCszowd4A3dVeUmh0EotNnqmitKzp8CLb7fXWx9O9gKQdwP0Vd1HzImtdgBG9xPq6khfmcKO9CM(DOomtKzAWydS)kfs7ngEDREIcsHx9aJPo(nnvoPaUxGwx9yOcGMWL5G2Zzkuf4F4TMHP9gKO9CM(DOomtKzAWydS)kfs7ni)(aqfl(TWFCXWRB1tuqk8Qhym1XVPPYjL5ynGRDp8s4YCq75mD2aXGmrM9WZvgSxedF1J2BqMU6Gvk97qDyMiZ0GXgy)vkKUYrbJaz6O9CM(DOomtKzAWydS)kfs7njtAfcaHarff4TDgAhdvkEF)kic5cYVpauXIpc5WVBnzsyZaaM643ui1g4xXa3lqRRET0ks0EotHQa)dV1mmT3G0keacbIkkWB7m0ogQu8((vWw48SePLmj3QdwP0Vd1HzImtdgBG9xPq6khfmIKjTcbGqGOIoW(RuhWqbouP499RGTWbovV6bPq1THzO9CEy(5zj4NwtZWRB1tuqk8Qhym1XVPPYjL5ynGRDp8s4YCGndayQJFtHuBGFfdCVaTU6HWqrYnHqPzG)hdgiSHP4LXdg4OGHKBCVwwGFJoBGyqMiZE45kd2lIHV6rhx7xtZiqMo3QdwP0Vd1HzImtdgBG9xPq6khfmIKjr75m97qDyMiZ0GXgy)vkK2BsM0keacbIkkWB7m0ogQu8((vqeYfKFFaOIfFeYHF3AAgEDREIcsHx9aJPo(nnvoPa82odTJHAcxMJviaecevm8CRImDUr75m97qDyMiZ0GXgy)vkK2BqI2Zz6zxUJ5J2BsZWRB1tuqk8Qhym1XVPPYjfG32zODmut4YCScbGqGOIHNBvK2ah)geHQdwP0zdemrMPbJnW(RuiDLJcgbsUr75m9Sl3X8r7ngEDREIcsHx9aJPo(nnvoPa82odTJHAcxMJ6GvkD2abtKzAWydS)kfsx5OGrGKB0Eot)ouhMjYmnySb2FLcP9gKFFaOIfFeYbb5csUr75mD2aXGmrM9WZvgSxedF1J2Bm86w9efKcV6bgtD8BAQCszowdyWaHnCcxMt64ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMrKmjSzaatD8BkKAd8RyG7fO1vVwAnnKPRoyLs)ouhMjYmnySb2FLcPRCuWiqYnApNPZgigKjYShEUYG9Iy4RE0EdY0r75m97qDyMiZ0GXgy)vkK2BsM87davS4Jqo87wtMe2maGPo(nfsTb(vmW9c06QxlTIeTNZuOkW)WBndt7niTcbGqGOIc82odTJHkfVVFfSfoplrAjtYT6Gvk97qDyMiZ0GXgy)vkKUYrbJizsRqaieiQOdS)k1bmuGdvkEF)kylCGt1REqkuDBygApNhMFEwc(P10m86w9efKcV6bgtD8BAQCsjJfqLbde2WjCzoQdwP0ZUChZhDLJcgbs1bRu63H6WmrMPbJnW(RuiDLJcgbs0Eotp7YDmF0Eds0Eot)ouhMjYmnySb2FLcP9gdVUvprbPWREGXuh)MMkNuaEBNH2XqnHlZbTNZuhAxr4LD0EJHx3QNOGu4vpWyQJFttLtkaVTZq7yOMWL5yfcaHarfdp3Qi5wDWkL(DOomtKzAWydS)kfsx5OGry41T6jkifE1dmM6430u5KYzxUJ5lHlZrDWkLE2L7y(ORCuWiqYD6FFaOIfFeIaiisRqaieiQOaVTZq7yOsX77xbBHdxsZWRB1tuqk8Qhym1XVPPYjLmwavgmqydNWL5OoyLsp7YDmF0vokyeir75m9Sl3X8r7nithTNZ0ZUChZhfVVFfSLNLGFqC(bTNZ0ZUChZhfQUnCYKO9CMcvb(hERzyAVjzsUvhSsPFhQdZezMgm2a7VsH0vokyePz41T6jkifE1dmM6430u5KcWB7m0ogQgEDREIcsHx9aJPo(nnvoPKb(FmyGWgoblFwWyQJFtHCcnHlZbVmEWahfmdVUvprbPWREGXuh)MMkNuYybuzWaHnCcxMdUxllWVrhy)vQdyJR9dCO4R)PJR9RPzei5gTNZ0b2FL6a24A)ahk(6FgXq75mT3GKB1bRu6a7VsDadf4qLUYrbJaj3QdwP0zdex9yWaHnmDLJcgHHx3QNOGu4vpWyQJFttLtk2a)kwGJBpOA41T6jkifE1dmM6430u5KsglGkdgiSHt4YCuhSsPND5oMp6khfmcKO9CME2L7y(O9gdVUvprbPWREGXuh)MMkNuGQRNLrCqBGJFlHlZrDWkLcvxplJ4G2ah)gDLJcgHHx3QNOGu4vpWyQJFttLtkZXAaBG9xPoiHlZHB1bRuAd((oGnW(RuhCqLUYrbJizsUBMsZhESb2FL6aQB1R9m86w9efKcV6bgtD8BAQCsXg4xXa3lqRREjCzoWMbam1XVPqQnWVIbUxGwx9qyOgEDREIcsHx9aJPo(nnvoPaUxGwx9yOcGA41T6jkifE1dmM6430u5Ksg4)XGbcB4e(I2x94eAcw(SGXuh)Mc5eAcxMdEz8GbokygEDREIcsHx9aJPo(nnvoPKb(FmyGWgoHVO9vpoHMWL58fT3FLsjoO6LDiK)m86w9efKcV6bgtD8BAQCsjJfqLbde2Wj8fTV6XjudVUvprbPWREGXuh)MMkNuYybuzWaHnCcxMJ6Gvk9Sl3X8rx5OGrGeTNZ0ZUChZhT3GeTNZ0ZUChZhfVVFfSf4u9QhKcv3gMH2Z5H5NNLGFq75m9Sl3X8rHQBdljBpm8eLKNw5sRHYf(fxqajjICCD1dkj5)(ncSoctebnr3QNOmrWbvi1WRK07AGaljjVFh46jkeRypRssWbvOmrjj8Qhym1XVPYeL8eQmrj5khfmczissl(0HpxsMUjI2Zzkuf4F4TMHP499RGMylMiCQE1dsHQBdZq758WMi)yIplHjYpMiApNPqvG)H3AgMcv3g2etts6w9eLKeCVaTU6XqfavQsEAvMOKCLJcgHmejPfF6WNljvhSsPND5oMp6khfmctePjI2Zz6zxUJ5J2BmrKMiApNPND5oMpkEF)kOj2IjcNQx9GuO62Wm0EopSjYpM4ZsyI8JjI2Zz6zxUJ5Jcv3gws6w9eLKmJfqLbde2WsvYdcitusUYrbJqgIK0T6jkjzg4)XGbcByjPfF6WNljt3e52e1Zg(QNjMmPjsiuAg4)XGbcBykEF)kOj2cht8zjmXKjnr1bRuQdTRi8Yo6khfmctePjsiuAg4)XGbcBykEF)kOj2IjMUjAfcaHarf1H2veEzhfVVFf0et1er75m1H2veEzhLOJD9eLjMMjI0eTcbGqGOI6q7kcVSJI33VcAITyIiUjMMjI0et3er75mf4TDgSJFJ2BmXKjnrUnr0EotrbcbbOdvAVXettsA5ZcgtD8BkuYtOsvYdIltusUYrbJqgIK0T6jkjzg4)XGbcByjPfF6WNljr75mTbFFbM4CadrE7r7nMisteVmEWahfmjPLplym1XVPqjpHkvjpiOmrj5khfmczissl(0HpxsQoyLsDODfHx2rx5OGryIinX0nr9(ZerihtK)4IjMmPjI2ZzkkqiiaDOs7nMyAMistmDt0keacbIkkWB7m0ogQu8((vqteHMixmX0mrKMy6Mi3MO6Gvk9Sl3X8rx5OGryIjtAICBIO9CME2L7y(O9gtePjYTjAfcaHarf9Sl3X8r7nMyAss3QNOKKo0UIWl7KQKh(tMOKCLJcgHmejPfF6WNljr75mf4TDgSJFJ2BmrKMy6MiUxllWVrr0veWM5HhgYaEBNHhSJFRSJoU2VMMryIjtAICBIO9CM(DOomtKzAWydS)kfs7nMistuDWkL(DOomtKzAWydS)kfsx5OGryIPjjDREIssc82odTJHQuL8WVKjkjx5OGridrsAXNo85ss1bRu6a7VsDadf4qLUYrbJWerAIPBIFFaOIfFtSftKFXftmnjPB1tusYb2FL6agkWHQuL8W)Kjkjx5OGridrsAXNo85ss1bRukuf4F4TMHPRCuWimrKMy6Mi2pc2AVsPobbKAf9snXwmreWetM0eX(rWw7vk1jiG0RmreAIiixmX0mrKMy6M43haQyX3eBXerCe3etts6w9eLKeQc8p8wZWsvYd)wMOKCLJcgHmejPfF6WNljvhSsPZgiU6XGbcBy6khfmctePjAfcaHarff4TDgAhdvkEF)kOj2cht8zjKKUvprjjNnqC1Jbde2WsvYtOCrMOKCLJcgHmejPfF6WNljvhSsPZgiU6XGbcBy6khfmctePjI2Zz6SbIREmyGWgM2BKKUvprjjbEBNH2XqvQsEcnuzIsYvokyeYqKKw8PdFUKuDWkLcoU2pc23FFNPcDF6khfmcjPB1tussWX1(rW((77mvO7lvjpH2Qmrj5khfmczissl(0HpxsI2Zz6SbIbzIm7HNRmyVig(QhT3yIinr1bRu63H6WmrMPbJnW(RuiDLJcgHjI0er75m97qDyMiZ0GXgy)vkK2BKKUvprjjNJ1aU29WtQsEcfbKjkjx5OGridrsAXNo85ss0EotHQa)dV1mmT3yIinr0Eot)ouhMjYmnySb2FLcP9gtePj(9bGkw8nXwmr(Jlss3QNOKKG7fO1vpgQaOsvYtOiUmrj5khfmczissl(0HpxsI2Zz6SbIbzIm7HNRmyVig(QhT3yIinX0nr1bRu63H6WmrMPbJnW(RuiDLJcgHjI0et3er75m97qDyMiZ0GXgy)vkK2BmXKjnrRqaieiQOaVTZq7yOsX77xbnreAICXerAIFFaOIfFteHCmr(DRMyYKMiSzaatD8BkKAd8RyG7fO1vptSftSvtePjI2Zzkuf4F4TMHP9gtePjAfcaHarff4TDgAhdvkEF)kOj2cht8zjmX0mXKjnrUnr1bRu63H6WmrMPbJnW(RuiDLJcgHjMmPjAfcaHarfDG9xPoGHcCOsX77xbnXw4yIWP6vpifQUnmdTNZdBI8Jj(SeMi)yITAIPjjDREIssohRbCT7HNuL8ekcktusUYrbJqgIK0IpD4ZLKWMbam1XVPqQnWVIbUxGwx9mreAIHAIinrUnrcHsZa)pgmqydtXlJhmWrbZerAICBI4ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMryIinX0nrUnr1bRu63H6WmrMPbJnW(RuiDLJcgHjMmPjI2Zz63H6WmrMPbJnW(RuiT3yIjtAIwHaqiqurbEBNH2XqLI33VcAIi0e5IjI0e)(aqfl(Mic5yI87wnX0KKUvprjjNJ1aU29WtQsEcL)Kjkjx5OGridrsAXNo85ssRqaieiQy45w1erAIPBICBIO9CM(DOomtKzAWydS)kfs7nMisteTNZ0ZUChZhT3yIPjjDREIssc82odTJHQuL8ek)sMOKCLJcgHmejPfF6WNljTcbGqGOIHNBvtePjAdC8BqteHMO6GvkD2abtKzAWydS)kfsx5OGryIinrUnr0Eotp7YDmF0EJK0T6jkjjWB7m0ogQsvYtO8pzIsYvokyeYqKKw8PdFUKuDWkLoBGGjYmnySb2FLcPRCuWimrKMi3MiApNPFhQdZezMgm2a7VsH0EJjI0e)(aqfl(Mic5yIiixmrKMi3MiApNPZgigKjYShEUYG9Iy4RE0EJK0T6jkjjWB7m0ogQsvYtO8BzIsYvokyeYqKKw8PdFUKmDte3RLf43OZgigKjYShEUYG9Iy4RE0X1(10mctmzste2maGPo(nfsTb(vmW9c06QNj2Ij2QjMMjI0et3evhSsPFhQdZezMgm2a7VsH0vokyeMistKBteTNZ0zdedYez2dpxzWErm8vpAVXerAIPBIO9CM(DOomtKzAWydS)kfs7nMyYKM43haQyX3erihtKF3QjMmPjcBgaWuh)McP2a)kg4EbAD1ZeBXeB1erAIO9CMcvb(hERzyAVXerAIwHaqiqurbEBNH2XqLI33VcAITWXeFwctmntmzstKBtuDWkL(DOomtKzAWydS)kfsx5OGryIjtAIwHaqiqurhy)vQdyOahQu8((vqtSfoMiCQE1dsHQBdZq758WMi)yIplHjYpMyRMyAss3QNOKKZXAadgiSHLQKNw5Imrj5khfmczissl(0HpxsQoyLsp7YDmF0vokyeMistuDWkL(DOomtKzAWydS)kfsx5OGryIinr0Eotp7YDmF0EJjI0er75m97qDyMiZ0GXgy)vkK2BKKUvprjjZybuzWaHnSuL80AOYeLKRCuWiKHijT4th(CjjApNPo0UIWl7O9gjPB1tussG32zODmuLQKNwBvMOKCLJcgHmejPfF6WNljTcbGqGOIHNBvtePjYTjQoyLs)ouhMjYmnySb2FLcPRCuWiKKUvprjjbEBNH2XqvQsEAfbKjkjx5OGridrsAXNo85ss1bRu6zxUJ5JUYrbJWerAICBIPBIFFaOIfFteHMicGGMist0keacbIkkWB7m0ogQu8((vqtSfoMixmX0KKUvprjjp7YDmFsvYtRiUmrj5khfmczissl(0HpxsQoyLsp7YDmF0vokyeMisteTNZ0ZUChZhT3yIinX0nr0Eotp7YDmFu8((vqtSft8zjmr(XerCtKFmr0Eotp7YDmFuO62WMyYKMiApNPqvG)H3AgM2BmXKjnrUnr1bRu63H6WmrMPbJnW(RuiDLJcgHjMMK0T6jkjzglGkdgiSHLQKNwrqzIss3QNOKKaVTZq7yOkjx5OGridrQsEAL)Kjkjx5OGridrs6w9eLKmd8)yWaHnSK0IpD4ZLK4LXdg4OGjjT8zbJPo(nfk5juPk5Pv(Lmrj5khfmczissl(0HpxsI71Yc8B0b2FL6a24A)ahk(6F64A)AAgHjI0e52er75mDG9xPoGnU2pWHIV(Nrm0Eot7nMistKBtuDWkLoW(RuhWqbouPRCuWimrKMi3MO6GvkD2aXvpgmqydtx5OGrijDREIssMXcOYGbcByPk5Pv(NmrjPB1tussBGFflWXThuLKRCuWiKHivjpTYVLjkjx5OGridrsAXNo85ss1bRu6zxUJ5JUYrbJWerAIO9CME2L7y(O9gjPB1tusYmwavgmqydlvjpiaxKjkjx5OGridrsAXNo85ss1bRukuD9SmIdAdC8B0vokyess3QNOKKq11ZYioOnWXVjvjpiqOYeLKRCuWiKHijT4th(Cjj3MO6GvkTbFFhWgy)vQdoOsx5OGryIjtAICBIntP5dp2a7VsDa1T61Ess3QNOKKZXAaBG9xPoqQsEqGwLjkjx5OGridrsAXNo85ssyZaaM643ui1g4xXa3lqRREMicnXqLKUvprjjTb(vmW9c06QNuL8GaiGmrjPB1tussW9c06Qhdvauj5khfmczisvYdcG4YeLKFr7REsEcvsUYrbJ9fTV6jdrs6w9eLKmd8)yWaHnSK0YNfmM643uOKNqLKw8PdFUKeVmEWahfmj5khfmczisvYdcGGYeLKRCuWiKHijx5OGX(I2x9KHijT4th(Cj5x0E)vkL4GQx2zIi0e5pjPB1tusYmW)Jbde2WsYVO9vpjpHkvjpia)jtus(fTV6j5juj5khfm2x0(QNmejPB1tusYmwavgmqydljx5OGridrQsEqa(Lmrj5khfmczissl(0HpxsQoyLsp7YDmF0vokyeMisteTNZ0ZUChZhT3yIinr0Eotp7YDmFu8((vqtSfteovV6bPq1THzO9CEytKFmXNLWe5hteTNZ0ZUChZhfQUnSK0T6jkjzglGkdgiSHLQuLKel7DGktuYtOYeLKRCuWiKHijjg0IVg9eLKK)R0HX9g1efzt06qfsLKUvprjjr0vemyWCSuL80Qmrj5x0(QNKNqLKRCuWyFr7REYqKKUvprjjHnh(ue5GWddzpSBNKCLJcgHmePk5bbKjkjDREIss2i0tusYvokyeYqKQKhexMOK0T6jkjzho2P7dLKRCuWiKHivjpiOmrj5khfmczissl(0HpxsMUjYTjQoyLshy)vQdyOahQ0vokyeMyAMistKBtupB4REMistKBtSzkfQc8NnW(RuhqDRETNjI0et3eHndayQJFtHuBGFfdCVaTU6zITyIiGjMmPjQoyLs)ouhMjYmnySb2FLcPRCuWimXKjnrCVwwGFJcdZhkEE4HHS8nmFmI9p4OJR9RPzeMyAss3QNOKKzG)hdgiSHLQKh(tMOKCLJcgHmejPB1tusYg89fyIZbme5TNK0IpD4ZLKCBIO9CM2GVVatCoGHiV9O9gtePjMUjYTj2mLcvb(Zgy)vQdOUvV2ZetM0eHndayQJFtHuBGFfdCVaTU6zITyIiGjI0er75mfrxrWEDOsHQBdBITyITYftmzstek6a0RiOG5emu(ydXI)BaJUYrbJWetZerAIPBIWMbam1XVPqQnWVIbUxGwx9mXwmre0etM0evhSsPFhQdZezMgm2a7VsH0vokyeMyYKMiUxllWVrHH5dfpp8Wqw(gMpgX(hC0X1(10mctmzstek6a0RiOG5emu(ydXI)BaJUYrbJWettsA5ZcgtD8BkuYtOsvYd)sMOKCLJcgHmejPfF6WNlj52e1Zg(QNjI0et3e52eBMsHQa)zdS)k1bu3Qx7zIjtAIWMbam1XVPqQnWVIbUxGwx9mXwmreWerAIO9CMIORiyVouPq1THnXwmXw5IjMMjI0et3eHndayQJFtHuBGFfdCVaTU6zITyIiGjMmPjQoyLs)ouhMjYmnySb2FLcPRCuWimXKjnrCVwwGFJcdZhkEE4HHS8nmFmI9p4OJR9RPzeMyAss3QNOKKzG)hdgiSHLQKh(NmrjPB1tusY8HhBG9xPoqsUYrbJqgIuL8WVLjkjDREIss(NobwsUYrbJqgIuL8ekxKjkjx5OGridrsAXNo85ssUnr1bRuQdTRi8Yo6khfmctmzsteTNZuhAxr4LD0EJjMmPjAfcaHarf1H2veEzhfVVFf0erOjIGCrs6w9eLKefieeSChZNuL8eAOYeLKRCuWiKHijT4th(Cjj3MO6Gvk1H2veEzhDLJcgHjMmPjI2ZzQdTRi8YoAVrs6w9eLKeDy4WHV6jvjpH2Qmrj5khfmczissl(0HpxsYTjQoyLsDODfHx2rx5OGryIjtAIO9CM6q7kcVSJ2BmXKjnrRqaieiQOo0UIWl7O499RGMicnreKlss3QNOKK5dpuGqqivjpHIaYeLKRCuWiKHijT4th(Cjj3MO6Gvk1H2veEzhDLJcgHjMmPjI2ZzQdTRi8YoAVXetM0eTcbGqGOI6q7kcVSJI33VcAIi0erqUijDREIss6LDqf7aM1baPk5juexMOKCLJcgHmejPfF6WNlj52evhSsPo0UIWl7ORCuWimXKjnrUnr0EotDODfHx2r7nss3QNOKKO(JjYmfF2WqPk5jueuMOK0T6jkjz7bBgMPcDFj5khfmczisvYtO8Nmrj5khfmczissl(0HpxsAfTx5LsR7fOSSptePjYTjI71Yc8Bu4gbKjYmS)B8szpSarAaDCTFnnJWerAIPBICBIQdwP0Vd1HzImtdgBG9xPq6khfmctmzsteTNZ0Vd1HzImtdgBG9xPqAVXetZerAIWMbam1XVPqQnWVIbUxGwx9mXwmreqs6w9eLKm7JPyVG5o8eLuL8ek)sMOKCLJcgHmejPfF6WNljTI2R8sP19cuw2NjI0eX9Azb(nkCJaYezg2)nEPShwGinGoU2VMMryIinX0nrUnr1bRu63H6WmrMPbJnW(RuiDLJcgHjMmPjI2Zz63H6WmrMPbJnW(RuiT3yIjtAIWMbam1XVPqQnWVIbUxGwx9mreYXeratmntePjMUjAfcaHarfnF4Xgy)vQdO499RGMicnXw5IjMmPjAfcaHarffQc8NnW(RuhqX77xbnreAITYftmnjPB1tusYSpMI9cM7WtusvYtO8pzIsYvokyeYqKKw8PdFUK0T61ESv7FdAIi0eB1erAIPBIWMbam1XVPqQnWVIbUxGwx9mreAITAIjtAIWMbam1XVPqkWB7m05FteHMyRMyAss3QNOKK4EXCREIIboOkjbhuzL)NK0ftQsEcLFltusUYrbJqgIK0IpD4ZLKCBIQdwPuOkWF2a7VsDaDLJcgHjI0eDREThB1(3GMylCmXwLKqfFwvYtOss3QNOKK4EXCREIIboOkjbhuzL)NKeE1dmM643uPk5PvUitusUYrbJqgIK0IpD4ZLKQdwPuOkWF2a7VsDaDLJcgHjI0eDREThB1(3GMylCmXwLKqfFwvYtOss3QNOKK4EXCREIIboOkjbhuzL)NKeog8Qhym1XVPsvQsYg8SIpQRYeL8eQmrj5khfmcziss3QNOKKZXAaBG9xPoqssmOfFn6jkjjIjelZ21ryIR9W8zI69NjQbZeDRkWM4bnrVTFahfmQK0IpD4ZLKCBIQdwP0g89DaBG9xPo4GkDLJcgHuL80Qmrj5khfmcziss3QNOKKqvG)H3AgwssmOfFn6jkjjInWzIKQa)dV1mSj2GNv8rD1e7fyqOjcf)zIobb0er0baMiSXruzIqHOOssl(0HpxsQoyLsHQa)dV1mmDLJcgHjI0et3eX(rWw7vk1jiGuROxQj2IjIaMyYKMi2pc2AVsPobbKELjIqteb5IjMMuL8GaYeLKUvprjjZhESb2FL6aj5khfmczisvYdIltusUYrbJqgIK0IpD4ZLKQdwP0b2FL6agkWHkDLJcgHjI0eHndayQJFtHuBGFfdCVaTU6zITyIiGK0T6jkj5a7VsDadf4qvQsEqqzIsYvokyeYqKKUvprjjbEBNH2XqvscUAmlHKebKKw8PdFUKKBtuDWkLoW(RuhWqbouPRCuWimrKMiSzaatD8BkKAd8RyG7fO1vptSftebmXKjnr0EotHQa)dV1mmT3ijjg0IVg9eLKmKz9oCMi)V2HyIbo0eDtuXE7bmr9(lbtudMj6eeIYeBaUDqtKF0GdAIRumF8JjkkteXkITMywGnreWeHZkkcOjQct0BloctKq0rbdXm)V2HyIIYeB6aavQsE4pzIsYvokyeYqKKw8PdFUKKBtuDWkLoW(RuhWqbouPRCuWimrKMiSzaatD8BkKAd8RyG7fO1vpteHCmreWerAICBIO9CMcvb(hERzyAVrs6w9eLK0g4xXa3lqRREsvYd)sMOK0T6jkjzJqprjjx5OGridrQsvs6IjtuYtOYeLKUvprjjHQa)zdS)k1bsYvokyeYqKQKNwLjkjx5OGridrsAXNo85ss0EotToaWa3lqRREu8((vqteHCmXq5IK0T6jkj54BmrMPbJbvb(lvjpiGmrj5khfmczissl(0HpxsI2Zz6SbIREmyGWgM2BKKUvprjjNJ1aU29WtQsEqCzIss3QNOKK2a)kwGJBpOkjx5OGridrQsEqqzIsYvokyeYqKKw8PdFUKuDWkLcvb(hERzy6khfmcjPB1tussOkW)WBndlvjp8Nmrj5khfmcziss3QNOKKzG)hdgiSHLKw8PdFUKeVmEWahfmtePjMUjMUj6w9ApgHqPzG)hdgiSHnXwmXwnrKMOB1R9yR2)g0eBHJjIaMist0keacbIkAd((cmX5agI82JI33VcAITyIHYFMist0kAVYlLwZIfabMWerAICBIntPqvG)Sb2FL6aQB1R9mXKjnr3Qx7Xieknd8)yWaHnSj2IjgQjI0eDREThB1(3GMic5yIiUjI0e52eBMsHQa)zdS)k1bu3Qx7zIinr1bRu63H6WmrMPbJnW(RuiDLJcgHjMMjMmPjMUjI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJWerAICBIntPqvG)Sb2FL6aQB1R9mX0mX0KKw(SGXuh)McL8eQuL8WVKjkjx5OGridrsAXNo85ssUnr3Qx7Xieknd8)yWaHnSjI0e52eBMsHQa)zdS)k1bu3Qx7zIinX0nr1bRu63H6WmrMPbJnW(RuiDLJcgHjMmPjI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJWetts6w9eLKmd8)yWaHnSuL8W)Kjkjx5OGridrsAXNo85ss1bRu6SbIREmyGWgMUYrbJWerAIFFaOIfFteHCmr(JlMistmDte3RLf43OZgigKjYShEUYG9Iy4RE0X1(10mctePjI2Zz6SbIbzIm7HNRmyVig(QhT3yIjtAICBI4ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMryIPjjDREIssoBG4QhdgiSHLQKh(Tmrj5khfmczissl(0HpxsQoyLsDODfHx2rx5OGryIinX0nrUnXMPuOkWF2a7VsDa1T61EMyAMistmDtKBtuDWkLE2L7y(ORCuWimXKjnrUnr0Eotp7YDmF0EJjI0e52eTcbGqGOIE2L7y(O9gtmnjPB1tusshAxr4LDsvYtOCrMOKCLJcgHmejPfF6WNljvhSsPGJR9JG9933zQq3NUYrbJqs6w9eLKeCCTFeSV)(otf6(svYtOHktusUYrbJqgIK0IpD4ZLKWMbam1XVPqQnWVIbUxGwx9mXwmre3erAIO9CM(DOomtKzAWydS)kfs7nMist87davS4BITyIiixKKUvprjjTb(vmW9c06QNuL8eARYeLKRCuWiKHijT4th(CjjUxllWVrNnqmitKzp8CLb7fXWx9OJR9RPzeMistKBteTNZ0zdedYez2dpxzWErm8vpAVrs6w9eLKCowdyWaHnSuL8ekcitusUYrbJqgIK0IpD4ZLKecLMb(FmyGWgMI33VcAIinryZaaM643ui1g4xXa3lqRREMylMiIBIinX0nrUnXMPuOkWF2a7VsDa1T61EMyAMistmDteTNZuG32zWo(nAVXerAICBIO9CM(DOomtKzAWydS)kfs7nMistuDWkL(DOomtKzAWydS)kfsx5OGryIPjjDREIssc82odTJHQuL8ekIltusUYrbJqgIK0IpD4ZLKWMbam1XVPqQnWVIbUxGwx9mreYXeB1erAICBI4ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMryIinX0nr1bRu63H6WmrMPbJnW(RuiDLJcgHjI0e)(aqfl(Mic5yIiixmrKMi3MiApNPFhQdZezMgm2a7VsH0EJjMMK0T6jkj5CSgW1UhEsvYtOiOmrj5khfmczissl(0HpxssiuAg4)XGbcBykEF)kOjI0er75mf4TDgSJFJ2BmrKMiApNPn47lWeNdyiYBpAVrs6w9eLKe4TDgAhdvPk5ju(tMOKCLJcgHmejPfF6WNljjeknd8)yWaHnmfVVFf0erAIWMbam1XVPqQnWVIbUxGwx9mXwmre3erAI4ETSa)gfgMpu88Wddz5By(ye7FWrhx7xtZimrKMiApNPaVTZGD8B0EJjI0evhSsPFhQdZezMgm2a7VsH0vokyeMistKBteTNZ0Vd1HzImtdgBG9xPqAVXerAIFFaOIfFteHCmreKlss3QNOKKaVTZq7yOkvjpHYVKjkjx5OGridrsAXNo85sscHsZa)pgmqydtX77xbnrKMy6My6MiSzaatD8BkKAd8RyG7fO1vptSfteXnrKMiUxllWVrHH5dfpp8Wqw(gMpgX(hC0X1(10mctePjQoyLs)ouhMjYmnySb2FLcPRCuWimX0mXKjnX0nr1bRu63H6WmrMPbJnW(RuiDLJcgHjI0e)(aqfl(Mic5yIiixmrKMi3MiApNPFhQdZezMgm2a7VsH0EJjI0et3e52eX9Azb(n6SbIbzIm7HNRmyVig(QhDCTFnnJWetM0er75mD2aXGmrM9WZvgSxedF1J2BmX0mrKMi3MiUxllWVrHH5dfpp8Wqw(gMpgX(hC0X1(10mctmntmnjPB1tussG32zODmuLQKNq5FYeLKRCuWiKHijT4th(CjjHqPzG)hdgiSHP499RGMiste2maGPo(nfsTb(vmW9c06QNjYXerCtePjI71Yc8Buyy(qXZdpmKLVH5JrS)bhDCTFnnJWerAIO9CMc82od2XVr7nMistuDWkL(DOomtKzAWydS)kfsx5OGryIinrUnr0Eot)ouhMjYmnySb2FLcP9gtePj(9bGkw8nreYXerqUijDREIssc82odTJHQuL8ek)wMOKCLJcgHmejPfF6WNljHndayQJFtHuBGFfdCVaTU6zIiKJj2QK0T6jkj5CSgW1UhEsvYtRCrMOKCLJcgHmejPfF6WNljr75mfQc8p8wZWu8((vqtSftebmr(XeFwctKFmr0EotHQa)dV1mmfQUnSK0T6jkjPnWVIbUxGwx9KQKNwdvMOKCLJcgHmejPfF6WNljr75mf4TDgSJFJ2BmrKMiSzaatD8BkKAd8RyG7fO1vptSfteXnrKMy6Mi3MyZukuf4pBG9xPoG6w9AptmntePjsiuAg4)XGbcByQE2Wx9KKUvprjjbEBNH2XqvQsEATvzIsYvokyeYqKKw8PdFUKuDWkLoW(RuhWqbouPRCuWimrKMiSzaatD8BkKAd8RyG7fO1vptSftebnrKMy6Mi3MyZukuf4pBG9xPoG6w9AptmnjPB1tusYb2FL6agkWHQuL80kcitusUYrbJqgIK0IpD4ZLKQdwPuhAxr4LD0vokyess3QNOKKaVTZqN)LQKNwrCzIss3QNOKK2a)kg4EbAD1tsUYrbJqgIuL80kcktusUYrbJqgIKCLJcg7lAF1tgIK0IpD4ZLKO9CMc82od2XVr7nMist0keacbIkgEUvLKUvprjjbEBNH2Xqvs(fTV6j5juPk5Pv(tMOK8lAF1tYtOsYvokySVO9vpziss3QNOKKzG)hdgiSHLKw(SGXuh)McL8eQK0IpD4ZLK4LXdg4OGjjx5OGridrQsEALFjtus(fTV6j5juj5khfm2x0(QNmejPB1tusYmwavgmqydljx5OGridrQsvschdE1dmM643uzIsEcvMOK0T6jkjjuf4pBG9xPoqsUYrbJqgIuL80Qmrj5khfmczissl(0HpxsI2ZzQ1bag4EbAD1JI33VcAIiKJjgkxKKUvprjjhFJjYmnymOkWFPk5bbKjkjx5OGridrsAXNo85ss1bRu6zxUJ5JUYrbJWerAIO9CME2L7y(O9gtePjI2Zz6zxUJ5JI33VcAITyIWP6vpifQUnmdTNZdBI8Jj(SeMi)yIO9CME2L7y(Oq1THnrKMiApNPi6kc2RdvkuDBytSftmu(NK0T6jkjzglGkdgiSHLQKhexMOKCLJcgHmejPfF6WNljvhSsPdS)k1bmuGdv6khfmcjPB1tusYb2FL6agkWHQuL8GGYeLKRCuWiKHijT4th(CjP6GvkfQc8p8wZW0vokyess3QNOKKqvG)H3AgwQsE4pzIsYvokyeYqKKw8PdFUKuDWkLoBG4QhdgiSHPRCuWimrKMOviaecevuG32zODmuP499RGMylCmXNLWerAIWMbam1XVPqQnWVIbUxGwx9mXwmXwnXKjnXVpauXIVjIqoMi)XftePjcBgaWuh)McP2a)kg4EbAD1ZerihtSvtePjMUjYTjI71Yc8B0zdedYez2dpxzWErm8vp64A)AAgHjMmPjI2Zz6SbIbzIm7HNRmyVig(QhT3yIPzIjtAIWMbam1XVPqQnWVIbUxGwx9mXwmXwnrKMiApNPi6kc2RdvkuDByteHCmXq5FMistmDtKBte3RLf43OZgigKjYShEUYG9Iy4RE0X1(10mctmzsteTNZ0zdedYez2dpxzWErm8vpAVXetZerAIFFaOIfFteHCmr(Jlss3QNOKKZgiU6XGbcByPk5HFjtusUYrbJqgIK0IpD4ZLKPBIO9CMIORiyVouPq1THnXwmXq5FMistKBteTNZuuGqqa6qL2BmX0mXKjnr0EotbEBNb743O9gjPB1tussG32zODmuLQKh(Nmrj5khfmczissl(0HpxsQoyLsNnqC1Jbde2W0vokyeMisteTNZ0zdex9yWaHnmT3yIinryZaaM643ui1g4xXa3lqRREMylMyRss3QNOKKaVTZq7yOkvjp8BzIsYvokyeYqKKw8PdFUKuDWkLoBG4QhdgiSHPRCuWimrKMiApNPZgiU6XGbcByAVXerAIWMbam1XVPqQnWVIbUxGwx9mreYXeBvs6w9eLKCowd4A3dpPk5juUitusUYrbJqgIK0IpD4ZLKO9CMcvb(hERzyAVrs6w9eLKeCVaTU6XqfavQsEcnuzIsYvokyeYqKKw8PdFUKeTNZ0zdedYez2dpxzWErm8vpAVrs6w9eLKCowd4A3dpPk5j0wLjkjx5OGridrsAXNo85ssyZaaM643ui1g4xXa3lqRREMylMyRMist87davS4BIiKJjYFCXerAIPBIO9CMIORiyVouPq1THnXwmXw5IjMmPj(9bGkw8nreAI8BUyIPzIjtAIPBI4ETSa)gD2aXGmrM9WZvgSxedF1JoU2VMMryIinrUnr0EotNnqmitKzp8CLb7fXWx9O9gtmnjPB1tusY5ynGbde2WsvYtOiGmrj5khfmczissl(0HpxsMUjcBgaWuh)McP2a)kg4EbAD1ZerOjgQjMMjI0et3e52ejeknd8)yWaHnmfVmEWahfmtmnjPB1tusY5ynGRDp8KQKNqrCzIsYvokyeYqKKw8PdFUK0T61ESv7FdAIi0ed1erAIntPqvG)Sb2FL6aQB1R9mrKMiApNPOaHGa0HkT3ijDREIssAd8RyG7fO1vpPk5jueuMOKCLJcgHmejPfF6WNljBMsHQa)zdS)k1bu3Qx7zIinr0EotrbcbbOdvAVrs6w9eLKeCVaTU6XqfavQsEcL)Kjkjx5OGridrsAXNo85ss0EotDODfHx2r7nss3QNOKKaVTZq7yOkvjpHYVKjkjx5OGridrsAXNo85ssRqaieiQy45wvs6w9eLKe4TDgAhdvPk5ju(Nmrj5khfmczissl(0HpxsAfcaHarfdp3QMist0g443GMicnr1bRu6SbcMiZ0GXgy)vkKUYrbJqs6w9eLKe4TDgAhdvPk5ju(Tmrj5khfmczissl(0HpxsQoyLsp7YDmF0vokyeMisteTNZ0ZUChZhT3ijDREIssMXcOYGbcByPk5PvUitus6w9eLK0g4xXcCC7bvj5khfmczisvYtRHktusUYrbJqgIK0IpD4ZLKQdwPuO66zzeh0g443ORCuWiKKUvprjjHQRNLrCqBGJFtQsEATvzIsYvokyeYqKKw8PdFUKKBtuDWkL2GVVdydS)k1bhuPRCuWimXKjnr1bRuAd((oGnW(RuhCqLUYrbJWerAIPBICBIntPqvG)Sb2FL6aQB1R9mX0KKUvprjjNJ1a2a7VsDGuL80kcitusUYrbJqgIK0IpD4ZLKUvV2JTA)BqteHMyOMistmDte2maGPo(nfsTb(vmW9c06QNjIqtmutmzste2maGPo(nfsbEBNHo)BIi0ed1etts6w9eLK0g4xXa3lqRREsvYtRiUmrjPB1tussW9c06Qhdvauj5khfmczisvYtRiOmrj5x0(QNKNqLKRCuWyFr7REYqKKUvprjjZa)pgmqydljT8zbJPo(nfk5jujPfF6WNljXlJhmWrbtsUYrbJqgIuL80k)jtusUYrbJqgIKCLJcg7lAF1tgIK0IpD4ZLKFr79xPuIdQEzNjIqtK)KKUvprjjZa)pgmqydlj)I2x9K8eQuL80k)sMOK8lAF1tYtOsYvokySVO9vpziss3QNOKKzSaQmyGWgwsUYrbJqgIuLQuLQuLsa]] )

end
