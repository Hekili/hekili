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
    spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
    spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

    spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
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

                if runeforge.windspeakers_lava_resurgence.enabled then
                    applyBuff( "lava_surge" )
                    applyBuff( "windspeakers_lava_resurgence" )
                end

                removeBuff( "echoing_shock" )
            end,

            auras = {
                windspeakers_lava_resurgence = {
                    id = 336065,
                    duration = 15,
                    max_stack = 1,
                },
            }
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
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental" )
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
                removeBuff( "windspeakers_lava_resurgence" )
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
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )
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

            impact = function ()
                applyDebuff( "target", "flame_shock" )
                applyBuff( "primordial_wave" )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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
                    if state.spec.enhancement then reduceCooldown( "feral_spirit", 9 )
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

    spec:RegisterPack( "Elemental", 20210707, [[dGeDecqiKkpsqPAtiXNakYOevCkrQwLGIELiLzjIClGOODHYVernmGshtqAzIk9mGitdOQUgqHTjOKVbevJdOkoNGcTobfyEaH7HK2hqYbbkQAHcIhkOGMiqrLUiqvYhbkQ4KafLvIumtGO0nfukXork9tGOqlvqPupfrtvq1vfukPVcefmwbLI9sXFjAWcDyQwmKEmLMmcxwzZs5ZagTaNwLxlcZwv3gIDl53OA4IYXbQSCOEoOPt66s12fv9DGuJhOk15rQA(IK9tytOMWnKeUodT5c2CdfSGCWcYzGf8agGpiLRHuPpBgYm3MWbMHSCKzibV(HSs93qM50)CNWeUHeY7y7mKbQMbddsozGtd6Omlhjz4H0FxpEzXEttgEi2KnKO97vWSYGAijCDgAZfS5gkyb5GfKZal4bma)Cb5gsy2SgAZnSY1qgCeeRmOgsIbTgsWRFiRu)frYahXlbn00F6frqEsIyUGn3qf0iOjmmWlGbdde0aYuebZklhNXXUoreovVcaYGQBtir7T2WIyJJfrWm7ADm9jjIKkhJKylByMGgqMIiyEccrmSLPJJfrVierWl6NiYBIOgmrKu5yer0b8RygYmmVD)mKH9WUicE9dzL6Visg4iEjOjSh2frA6p9IiipjrmxWMBOcAe0e2d7IyyyGxadggiOjSh2frqMIiywz54mo21jIWP6vaqguDBcjAV1gweBCSicMzxRJPpjrKu5yKeBzdZe0e2d7IiitrempbHig2Y0XXIOxeIi4f9te5nrudMisQCmIi6a(vmbncAc7Ii4f49SDDeI4Ypm9IOEite1GjIUv5yr8GION3V3r)Xe04w94fKLHNLJG6k15ynqUFiRu)t6AuPt9FLYYWhI)Y9dzL6)bv2kh9hHGMWUig2kCIiPYXij2YgweZWZYrqDve71piueHCKjIobbueb99VicZCqxIiKZlMGg3QhVGSm8SCeuxtJAYTFWal2BAsxJkK3F0RiyzDO2)jhUNPhVsLcY7p6veS88317NeY)8RubnUvpEbzz4z5iOUMg1KHkhJKylB4KUgv1)vkdQCmsITSHzRC0FeuYb7hHC5xPmNGaYS8EPGaKsLc7hHC5xPmNGaYUcuGbytxqJB1JxqwgEwocQRPrn52HNC)qwP(lOXT6Xlildplhb110OM8(HSs9xI(out6Auv)xPS9dzL6Ve9DOYw5O)iOaZ2)s1XatHmBGFL8pGaTUcaeGKGMWUigYSEhoreKnFiIyGdfrxevSNFViQhYsse1GjIobbVeXS3TdkIHPgCqrCLIPpmfrEjIHHG5kInowebjreolViGIOYfrpp)iercEh9hitq28HiI8seZ6)Ze04w94fKLHNLJG6AAut(98UeTJHAs)vtAjOcsjDnQ0P(Vsz7hYk1Fj67qLTYr)rqbMT)LQJbMcz2a)k5FabADfaiaPuPq7TgdQCmsITSHz9mbnUvpEbzz4z5iOUMg1KTb(vY)ac06kGKUgv6u)xPS9dzL6Ve9DOYw5O)iOaZ2)s1XatHmBGFL8pGaTUcauubjk0H2Bngu5yKeBzdZ6zcACRE8cYYWZYrqDnnQjNX1JxcAe0e2frWSshg3ZurK3erRdvitqJB1JxW0OMmOVIqcdMJf04w94fmnQjdZo8PG2)eddLay3UKq45VcGAOcACRE8cMg1KZ46XlbnUvpEbtJAYD4KNoeOGg3QhVGPrn527itcd42ejDnQ5qN6)kLTFiRu)LOVdv2kh9hr6uOtpBIRaOqx2ugu5ye5(HSs9N5w9Ypk5aZ2)s1XatHmBGFL8pGaTUcaeGuQuQ)RugId1HL8MudMC)qwPq2kh9hrQu4ETghdmgmb9O45jggkB3W0ljgYbhBGRFzzJiDbnUvpEbtJAYz4dHJjo)LG2ZVKS0B)jvhdmfsn0KUgv6q7TgldFiCmX5Ve0E(X6zuYHUSPmOYXiY9dzL6pZT6LFPsbZ2)s1XatHmBGFL8pGaTUcaeGef0ERXa9vesGouzq1TjarUGnvkiV)OxrW(5esu6Ld82rY(Xw5O)isNsoWS9VuDmWuiZg4xj)diqRRaabyKkL6)kLH4qDyjVj1Gj3pKvkKTYr)rKkfUxRXXaJbtqpkEEIHHY2nm9sIHCWXg46xw2isLcY7p6veSFoHeLE5aVDKSFSvo6pI0f04w94fmnQj3Ehzsya3MiPRrLo9SjUcGso0LnLbvogrUFiRu)zUvV8lvky2(xQogykKzd8RK)beO1vaGaKOG2BngOVIqc0HkdQUnbiYfSPtjhy2(xQogykKzd8RK)beO1vaGaKsLs9FLYqCOoSK3KAWK7hYkfYw5O)isLc3R14yGXGjOhfppXWqz7gMEjXqo4ydC9llBePlOXT6XlyAutUD4j3pKvQ)cACRE8cMg1KrMoowqJB1JxW0OMm6Z5eYwhtFsxJkDQ)RuMdTRi8Yo2kh9hrQuO9wJ5q7kcVSJ1ZsLYY5pbh0fZH2veEzhdpe)kiOadWkOXT6XlyAutgDy4WjUciPRrLo1)vkZH2veEzhBLJ(Jivk0ERXCODfHx2X6zcACRE8cMg1KBhEOpNtK01OsN6)kL5q7kcVSJTYr)rKkfAV1yo0UIWl7y9SuPSC(tWbDXCODfHx2XWdXVcckWaScACRE8cMg1K9YoOI9xA9)t6AuPt9FLYCODfHx2Xw5O)isLcT3AmhAxr4LDSEwQuwo)j4GUyo0UIWl7y4H4xbbfyawbnUvpEbtJAYOoGK3Kk(SjGjDnQ0P(Vszo0UIWl7yRC0FePsrhAV1yo0UIWl7y9mbnUvpEbtJAY5hmByPY1HiOXT6XlyAutU5tQyVGTo84vsxJQLNFLxkRoGav28rHoCVwJJbgdUraL8Me7izEPsamh0AaBGRFzzJGso0P(VsziouhwYBsnyY9dzLczRC0FePsH2BngId1HL8MudMC)qwPqwplDkWS9VuDmWuiZg4xj)diqRRaabijOXT6XlyAutU5tQyVGTo84vsxJQLNFLxkRoGav28rb3R14yGXGBeqjVjXosMxQeaZbTgWg46xw2iOKdDQ)RugId1HL8MudMC)qwPq2kh9hrQuO9wJH4qDyjVj1Gj3pKvkK1ZsLcMT)LQJbMcz2a)k5FabADfaOOcsPtjhlN)eCqxS2HNC)qwP(ZWdXVccQCbBQuwo)j4GUyqLJrK7hYk1FgEi(vqqLlytxqJB1JxW0OMmUxs3QhVK)b1KkhzuD(s6AuDRE5NC1qUbbvUuYbMT)LQJbMcz2a)k5FabADfaOYnvky2(xQogykK9EExIohbu5MUGg3QhVGPrnzCVKUvpEj)dQjvoYOcVc4NuDmW0KGk(Sk1qt6AuPt9FLYGkhJi3pKvQ)Svo6pckUvV8tUAi3GGGAUcACRE8cMg1KX9s6w94L8pOMu5iJkCs4va)KQJbMMeuXNvPgAsxJQ6)kLbvogrUFiRu)zRC0FeuCRE5NC1qUbbb1Cf0iOXT6XliZ5Jku5ye5(HSs9xqJB1JxqMZxAutE0pjVj1GjHkhJK01OI2BnM1)x(hqGwxbWWdXVcckQHcwbnUvpEbzoFPrn55ynaCDpXs6Aur7TgB2a(vasya3MG1Ze04w94fK58Lg1KTb(vYahNFqvqJB1JxqMZxAutgQCmsITSHt6Auv)xPmOYXij2YgMTYr)riOXT6XliZ5lnQj3Ehzsya3Mijl92Fs1XatHudnPRrfVgEWah9hLCYXT6LFscUYAVJmjmGBtaICP4w9Yp5QHCdccQGeflN)eCqxSm8HWXeN)sq75hdpe)kiicnSOy55x5LYQzX8NJjOqx2ugu5ye5(HSs9N5w9YVuPCRE5NKGRS27itcd42eGiukUvV8tUAi3GGIk4tHUSPmOYXiY9dzL6pZT6LFuu)xPmehQdl5nPgm5(HSsHSvo6pI0tLkhCVwJJbgdMGEu88eddLTBy6Led5GJnW1VSSrqHUSPmOYXiY9dzL6pZT6LFPNUGg3QhVGmNV0OMC7DKjHbCBIKUgv6CRE5NKGRS27itcd42euOlBkdQCmIC)qwP(ZCRE5hLCu)xPmehQdl5nPgm5(HSsHSvo6pIuPW9Anogymyc6rXZtmmu2UHPxsmKdo2ax)YYgr6cACRE8cYC(sJAYZgWVcqcd42ejDnQQ)Ru2Sb8RaKWaUnbBLJ(JGcIVhQyocOOgwGLso4ETghdm2Sb8bL8MeapxLWErm8vaSbU(LLnckO9wJnBaFqjVjbWZvjSxedFfaRNLkfD4ETghdm2Sb8bL8MeapxLWErm8vaSbU(LLnI0f04w94fK58Lg1KDODfHx2L01OQ(Vszo0UIWl7yRC0FeuYHUSPmOYXiY9dzL6pZT6LFPtjh6u)xPSZUwhtpBLJ(Jivk6q7Tg7SR1X0Z6zuOZY5pbh0f7SR1X0Z6zPlOXT6XliZ5lnQj)h46hHeXbqCPY1HK01OQ(Vsz)bU(rirCaexQCDiSvo6pcbnUvpEbzoFPrnzBGFL8pGaTUciPRrfMT)LQJbMcz2a)k5FabADfaiaFkO9wJH4qDyjVj1Gj3pKvkK1ZOG47HkMJacWaScACRE8cYC(sJAYZXAGegWTjs6AuX9AnogySzd4dk5njaEUkH9Iy4RaydC9llBeuOdT3ASzd4dk5njaEUkH9Iy4Ray9mbnUvpEbzoFPrn53Z7s0ogQjDnQeCL1Ehzsya3MGHhIFfKcmB)lvhdmfYSb(vY)ac06kaqa(uYHUSPmOYXiY9dzL6pZT6LFPtjh0ERXEpVlHDmWy9mk0H2BngId1HL8MudMC)qwPqwpJI6)kLH4qDyjVj1Gj3pKvkKTYr)rKUGg3QhVGmNV0OM8CSgaUUNyjDnQWS9VuDmWuiZg4xj)diqRRaaf1CPqhUxRXXaJnBaFqjVjbWZvjSxedFfaBGRFzzJGsoQ)RugId1HL8MudMC)qwPq2kh9hbfeFpuXCeqrfmalf6q7TgdXH6WsEtQbtUFiRuiRNLUGg3QhVGmNV0OM875DjAhd1KUgvcUYAVJmjmGBtWWdXVcsbT3AS3Z7syhdmwpJcAV1yz4dHJjo)LG2ZpwptqJB1JxqMZxAut(98UeTJHAsxJkbxzT3rMegWTjy4H4xbPaZ2)s1XatHmBGFL8pGaTUcaeGpfCVwJJbgdMGEu88eddLTBy6Led5GJnW1VSSrqbT3AS3Z7syhdmwpJI6)kLH4qDyjVj1Gj3pKvkKTYr)rqHo0ERXqCOoSK3KAWK7hYkfY6zuq89qfZrafvWaScACRE8cYC(sJAYVN3LODmut6Auj4kR9oYKWaUnbdpe)kiLCYbMT)LQJbMcz2a)k5FabADfaiaFk4ETghdmgmb9O45jggkB3W0ljgYbhBGRFzzJGI6)kLH4qDyjVj1Gj3pKvkKTYr)rKEQu5O(VsziouhwYBsnyY9dzLczRC0Feuq89qfZrafvWaSuOdT3AmehQdl5nPgm5(HSsHSEgLCOd3R14yGXMnGpOK3Ka45Qe2lIHVcGnW1VSSrKkfAV1yZgWhuYBsa8Cvc7fXWxbW6zPtHoCVwJJbgdMGEu88eddLTBy6Led5GJnW1VSSrKE6cACRE8cYC(sJAYVN3LODmut6Auj4kR9oYKWaUnbdpe)kify2(xQogykKzd8RK)beO1vaubFk4ETghdmgmb9O45jggkB3W0ljgYbhBGRFzzJGcAV1yVN3LWogySEgf1)vkdXH6WsEtQbtUFiRuiBLJ(JGcDO9wJH4qDyjVj1Gj3pKvkK1ZOG47HkMJakQGbyf04w94fK58Lg1KNJ1aW19elPRrfMT)LQJbMcz2a)k5FabADfaOOMRGg3QhVGmNV0OMSnWVs(hqGwxbK01OI2Bngu5yKeBzdZWdXVcccqkmbSeHjAV1yqLJrsSLnmdQUnHGg3QhVGmNV0OM875DjAhd1KUgv0ERXEpVlHDmWy9mkWS9VuDmWuiZg4xj)diqRRaab4tjh6YMYGkhJi3pKvQ)m3Qx(LofcUYAVJmjmGBtW0ZM4kabnUvpEbzoFPrn59dzL6Ve9DOM01OQ(Vsz7hYk1Fj67qLTYr)rqbMT)LQJbMcz2a)k5FabADfaiadk5qx2ugu5ye5(HSs9N5w9YV0f04w94fK58Lg1KFpVlrNJK01OQ(Vszo0UIWl7yRC0FecACRE8cYC(sJAY2a)k5FabADfGGg3QhVGmNV0OM875DjAhd1Kq45VcGAOjDnQO9wJ9EExc7yGX6zuSC(tWbDjXZTQGg3QhVGmNV0OMC7DKjHbCBIKq45VcGAOjzP3(tQogykKAOjDnQ41Wdg4O)e04w94fK58Lg1KByouLWaUnrsi88xbqnubncACRE8cYGtcVc4NuDmWuQqLJrK7hYk1FbnUvpEbzWjHxb8tQogyAAutE0pjVj1GjHkhJK01OI2BnM1)x(hqGwxbWWdXVcckQHcwbnUvpEbzWjHxb8tQogyAAutUH5qvcd42ejDnQQ)Ru2zxRJPNTYr)rqbT3ASZUwhtpRNrbT3ASZUwhtpdpe)kiiGt1RaGmO62es0ERnCycyjct0ERXo7ADm9mO62euq7Tgd0xrib6qLbv3MaeHcEe04w94fKbNeEfWpP6yGPPrn59dzL6Ve9DOM01OQ(Vsz7hYk1Fj67qLTYr)riOXT6Xlidoj8kGFs1XattJAYqLJrsSLnCsxJQ6)kLbvogjXw2WSvo6pcbnUvpEbzWjHxb8tQogyAAutE2a(vasya3MiPRrv9FLYMnGFfGegWTjyRC0FeuSC(tWbDXEpVlr7yOYWdXVcccQawckWS9VuDmWuiZg4xj)diqRRaarUPsH47HkMJakQHfyPaZ2)s1XatHmBGFL8pGaTUcauuZLso0H71ACmWyZgWhuYBsa8Cvc7fXWxbWg46xw2isLcT3ASzd4dk5njaEUkH9Iy4Ray9S0tLcMT)LQJbMcz2a)k5FabADfaiYLcAV1yG(kcjqhQmO62eGIAOGhk5qhUxRXXaJnBaFqjVjbWZvjSxedFfaBGRFzzJivk0ERXMnGpOK3Ka45Qe2lIHVcG1ZsNcIVhQyocOOgwGvqJB1JxqgCs4va)KQJbMMg1KFpVlr7yOM01OMdAV1yG(kcjqhQmO62eGiuWdf6q7Tgd95CIVdvwpl9uPq7Tg798Ue2XaJ1Ze04w94fKbNeEfWpP6yGPPrn53Z7s0ogQjDnQQ)Ru2Sb8RaKWaUnbBLJ(JGcAV1yZgWVcqcd42eSEgfy2(xQogykKzd8RK)beO1vaGixbnUvpEbzWjHxb8tQogyAAutEowdax3tSKUgv1)vkB2a(vasya3MGTYr)rqbT3ASzd4xbiHbCBcwpJcmB)lvhdmfYSb(vY)ac06kaqrnxbnUvpEbzWjHxb8tQogyAAut(pGaTUcqIYFnPRrfT3AmOYXij2YgM1Ze04w94fKbNeEfWpP6yGPPrn55ynaCDpXs6Aur7TgB2a(GsEtcGNRsyVig(kawptqJB1JxqgCs4va)KQJbMMg1KNJ1ajmGBtK01OcZ2)s1XatHmBGFL8pGaTUcae5sbX3dvmhbuudlWsjh0ERXa9vesGouzq1TjarUGnvkeFpuXCeqfgbB6PsLdUxRXXaJnBaFqjVjbWZvjSxedFfaBGRFzzJGcDO9wJnBaFqjVjbWZvjSxedFfaRNLUGg3QhVGm4KWRa(jvhdmnnQjphRbGR7jwsxJAoWS9VuDmWuiZg4xj)diqRRaavOPtjh6i4kR9oYKWaUnbdVgEWah9x6cACRE8cYGtcVc4NuDmW00OMSnWVs(hqGwxbK01O6w9Yp5QHCdcQqPKnLbvogrUFiRu)zUvV8JcAV1yOpNt8DOY6zcACRE8cYGtcVc4NuDmW00OM8FabADfGeL)AsxJA2ugu5ye5(HSs9N5w9YpkO9wJH(CoX3HkRNjOXT6Xlidoj8kGFs1XattJAYVN3LODmut6Aur7TgZH2veEzhRNjOXT6Xlidoj8kGFs1XattJAYVN3LODmut6AuTC(tWbDjXZTQGg3QhVGm4KWRa(jvhdmnnQj)EExI2XqnPRr1Y5pbh0Lep3QuSbogyqqP(VszZgWL8MudMC)qwPq2kh9hHGg3QhVGm4KWRa(jvhdmnnQj3WCOkHbCBIKUgv1)vk7SR1X0Zw5O)iOG2Bn2zxRJPN1Ze04w94fKbNeEfWpP6yGPPrnzBGFLmWX5huf04w94fKbNeEfWpP6yGPPrn52pyGf7nnPR0HX9mLAOjDnQqE)rVIGLN)UE)Kq(NFLkOXT6Xlidoj8kGFs1XattJAYq11ZkjoOnWXalPRrv9FLYGQRNvsCqBGJbgBLJ(JqqJB1JxqgCs4va)KQJbMMg1KNJ1a5(HSs9pPRrLo1)vkldFi(l3pKvQ)huzRC0FePsP(Vszz4dXF5(HSs9)GkBLJ(JGso0LnLbvogrUFiRu)zUvV8lDbnUvpEbzWjHxb8tQogyAAut2g4xj)diqRRas6AuDRE5NC1qUbbvOuYbMT)LQJbMcz2a)k5FabADfaOcnvky2(xQogykK9EExIohbuHMUGg3QhVGm4KWRa(jvhdmnnQj)hqGwxbir5VkOXT6Xlidoj8kGFs1XattJAYT3rMegWTjscHN)kaQHMKLE7pP6yGPqQHM01OIxdpyGJ(tqJB1JxqgCs4va)KQJbMMg1KBVJmjmGBtKecp)vaudnPRrfHNFiRugXbvVSduHLGg3QhVGm4KWRa(jvhdmnnQj3WCOkHbCBIKq45VcGAOcAe04w94fKbVc4NuDmWuQ)beO1vasu(RjDnQ5G2Bngu5yKeBzdZWdXVccc4u9kaidQUnHeT3AdhMawIWeT3AmOYXij2YgMbv3MiDbnUvpEbzWRa(jvhdmnnQj3WCOkHbCBIKUgv1)vk7SR1X0Zw5O)iOG2Bn2zxRJPN1ZOG2Bn2zxRJPNHhIFfeeWP6vaqguDBcjAV1gombSeHjAV1yNDToMEguDBcbnUvpEbzWRa(jvhdmnnQj3Ehzsya3Mijl92Fs1XatHudnPRrnh60ZM4kGuPi4kR9oYKWaUnbdpe)kiiOcyjsLs9FLYCODfHx2Xw5O)iOqWvw7DKjHbCBcgEi(vqqKJLZFcoOlMdTRi8YogEi(vW0q7TgZH2veEzhJOJD94v6uSC(tWbDXCODfHx2XWdXVcccWpDk5G2Bn275DjSJbgRNLkfDO9wJH(CoX3HkRNLUGg3QhVGm4va)KQJbMMg1KBVJmjmGBtKKLE7pP6yGPqQHM01OI2Bnwg(q4yIZFjO98J1ZOGxdpyGJ(tqJB1Jxqg8kGFs1XattJAYo0UIWl7s6Auv)xPmhAxr4LDSvo6pck5OhYaf1WcSPsH2Bng6Z5eFhQSEw6uYXY5pbh0f798UeTJHkdpe)kiOaB6uYHo1)vk7SR1X0Zw5O)isLIo0ERXo7ADm9SEgf6SC(tWbDXo7ADm9SEw6cACRE8cYGxb8tQogyAAut(98UeTJHAsxJkAV1yVN3LWogySEgLCW9AnogymqFfbmBEIHHY3Z7s8GDmWk7ydC9llBePsrhAV1yiouhwYBsnyY9dzLcz9mkQ)RugId1HL8MudMC)qwPq2kh9hr6cACRE8cYGxb8tQogyAAutE)qwP(lrFhQjDnQQ)Ru2(HSs9xI(ouzRC0FeuYbX3dvmhbeGCWMUGg3QhVGm4va)KQJbMMg1KHkhJKylB4KUgv1)vkdQCmsITSHzRC0FeuYb7hHC5xPmNGaYS8EPGaKsLc7hHC5xPmNGaYUcuGbytNsoi(EOI5iGa8b)0f04w94fKbVc4NuDmW00OM8Sb8RaKWaUnrsxJQ6)kLnBa)kajmGBtWw5O)iOy58NGd6I9EExI2XqLHhIFfeeubSecACRE8cYGxb8tQogyAAut(98UeTJHAsxJQ6)kLnBa)kajmGBtWw5O)iOG2Bn2Sb8RaKWaUnbRNjOXT6XlidEfWpP6yGPPrn5)ax)iKioaIlvUoKKUgv1)vk7pW1pcjIdG4sLRdHTYr)riOXT6XlidEfWpP6yGPPrn55ynaCDpXs6Aur7TgB2a(GsEtcGNRsyVig(kawpJI6)kLH4qDyjVj1Gj3pKvkKTYr)rqbT3AmehQdl5nPgm5(HSsHSEMGg3QhVGm4va)KQJbMMg1K)diqRRaKO8xt6Aur7TgdQCmsITSHz9mkO9wJH4qDyjVj1Gj3pKvkK1ZOG47HkMJaIWcScACRE8cYGxb8tQogyAAutEowdax3tSKUgv0ERXMnGpOK3Ka45Qe2lIHVcG1ZOKJ6)kLH4qDyjVj1Gj3pKvkKTYr)rqjh0ERXqCOoSK3KAWK7hYkfY6zPsz58NGd6I9EExI2XqLHhIFfeuGLcIVhQyocOOggZnvky2(xQogykKzd8RK)beO1vaGixkO9wJbvogjXw2WSEgflN)eCqxS3Z7s0ogQm8q8RGGGkGLi9uPOt9FLYqCOoSK3KAWK7hYkfYw5O)isLYY5pbh0fB)qwP(lrFhQm8q8RGGGkCQEfaKbv3MqI2BTHdtalryMB6cACRE8cYGxb8tQogyAAutEowdax3tSKUgvy2(xQogykKzd8RK)beO1vaGkuk0rWvw7DKjHbCBcgEn8Gbo6pk0H71ACmWyZgWhuYBsa8Cvc7fXWxbWg46xw2iOKdDQ)RugId1HL8MudMC)qwPq2kh9hrQuO9wJH4qDyjVj1Gj3pKvkK1ZsLYY5pbh0f798UeTJHkdpe)kiOalfeFpuXCeqrnmMB6cACRE8cYGxb8tQogyAAut(98UeTJHAsxJQLZFcoOljEUvPKdDO9wJH4qDyjVj1Gj3pKvkK1ZOG2Bn2zxRJPN1ZsxqJB1Jxqg8kGFs1XattJAYVN3LODmut6AuTC(tWbDjXZTkfBGJbgeuQ)Ru2SbCjVj1Gj3pKvkKTYr)rqHo0ERXo7ADm9SEMGg3QhVGm4va)KQJbMMg1KFpVlr7yOM01OQ(VszZgWL8MudMC)qwPq2kh9hbf6q7TgdXH6WsEtQbtUFiRuiRNrbX3dvmhbuubdWsHo0ERXMnGpOK3Ka45Qe2lIHVcG1Ze04w94fKbVc4NuDmW00OM8CSgiHbCBIKUg1CW9AnogySzd4dk5njaEUkH9Iy4RaydC9llBePsbZ2)s1XatHmBGFL8pGaTUcae5MoLCu)xPmehQdl5nPgm5(HSsHSvo6pck0H2Bn2Sb8bL8MeapxLWErm8vaSEgLCq7TgdXH6WsEtQbtUFiRuiRNLkfIVhQyocOOggZnvky2(xQogykKzd8RK)beO1vaGixkO9wJbvogjXw2WSEgflN)eCqxS3Z7s0ogQm8q8RGGGkGLi9uPOt9FLYqCOoSK3KAWK7hYkfYw5O)isLYY5pbh0fB)qwP(lrFhQm8q8RGGGkCQEfaKbv3MqI2BTHdtalryMB6cACRE8cYGxb8tQogyAAutUH5qvcd42ejDnQQ)Ru2zxRJPNTYr)rqr9FLYqCOoSK3KAWK7hYkfYw5O)iOG2Bn2zxRJPN1ZOG2BngId1HL8MudMC)qwPqwptqJB1Jxqg8kGFs1XattJAYVN3LODmut6Aur7TgZH2veEzhRNjOXT6XlidEfWpP6yGPPrn53Z7s0ogQjDnQwo)j4GUK45wLcDQ)RugId1HL8MudMC)qwPq2kh9hHGg3QhVGm4va)KQJbMMg1Kp7ADm9jDnQQ)Ru2zxRJPNTYr)rqHUCq89qfZrafibguSC(tWbDXEpVlr7yOYWdXVcccQGnDbnUvpEbzWRa(jvhdmnnQj3WCOkHbCBIKUgv1)vk7SR1X0Zw5O)iOG2Bn2zxRJPN1ZOKdAV1yNDToMEgEi(vqqayjctWpmr7Tg7SR1X0ZGQBtKkfAV1yqLJrsSLnmRNLkfDQ)RugId1HL8MudMC)qwPq2kh9hr6cACRE8cYGxb8tQogyAAut(98UeTJHQGg3QhVGm4va)KQJbMMg1KBVJmjmGBtKKLE7pP6yGPqQHM01OIxdpyGJ(tqJB1Jxqg8kGFs1XattJAYnmhQsya3MiPRrf3R14yGX2pKvQ)YbU(9hk(6iSbU(LLnck0H2Bn2(HSs9xoW1V)qXxhrsm0ERX6zuOt9FLY2pKvQ)s03HkBLJ(JGcDQ)Ru2Sb8RaKWaUnbBLJ(JqqJB1Jxqg8kGFs1XattJAYTFWal2BAsxPdJ7zk1qt6AuH8(JEfblp)D9(jH8p)kvqJB1Jxqg8kGFs1XattJAY2a)kzGJZpOkOXT6XlidEfWpP6yGPPrn5gMdvjmGBtK01OQ(VszNDToME2kh9hbf0ERXo7ADm9SEMGg3QhVGm4va)KQJbMMg1KHQRNvsCqBGJbwsxJQ6)kLbvxpRK4G2ahdm2kh9hHGg3QhVGm4va)KQJbMMg1KNJ1a5(HSs9pPRrLo1)vkldFi(l3pKvQ)huzRC0FePsrx2uw7WtUFiRu)zUvV8tqJB1Jxqg8kGFs1XattJAY2a)k5FabADfqsxJkmB)lvhdmfYSb(vY)ac06kaqfQGg3QhVGm4va)KQJbMMg1K)diqRRaKO8xf04w94fKbVc4NuDmW00OMC7DKjHbCBIKq45VcGAOjzP3(tQogykKAOjDnQ41Wdg4O)e04w94fKbVc4NuDmW00OMC7DKjHbCBIKq45VcGAOjDnQi88dzLYioO6LDGkSe04w94fKbVc4NuDmW00OMCdZHQegWTjscHN)kaQHkOXT6XlidEfWpP6yGPPrn5gMdvjmGBtK01OQ(VszNDToME2kh9hbf0ERXo7ADm9SEgf0ERXo7ADm9m8q8RGGaovVcaYGQBtir7T2WHjGLimr7Tg7SR1X0ZGQBtyiZpm84LH2CbBUHcwqoybddjODCDfa0qcYay(W20cMrlyoHbIOigEWeXdjJJvrSXXIiycEfWpP6yGPGjrepW1p8ierihzIO3voIRJqeTbEbmitqdi7vteZf8egiIHH8k)W6ierWeK3F0RiyHnGjru5IiycY7p6veSWg2kh9hbyseDvebVazeKveZjuW70zcAe0aYay(W20cMrlyoHbIOigEWeXdjJJvrSXXIiykdplhb1vWKiIh46hEeIiKJmr07khX1riI2aVagKjObK9QjI5ggiIHH8k)W6ierWeK3F0RiyHnGjru5IiycY7p6veSWg2kh9hbyseZjuW70zcAazVAIyUHbIyyiVYpSocremb59h9kcwydysevUicMG8(JEfblSHTYr)raMerxfrWlqgbzfXCcf8oDMGgbnGmaMpSnTGz0cMtyGikIHhmr8qY4yveBCSicMGtcVc4NuDmWuWKiIh46hEeIiKJmr07khX1riI2aVagKjObK9QjI5gAyGiggYR8dRJqebtqE)rVIGf2aMerLlIGjiV)OxrWcByRC0FeGjr0vre8cKrqwrmNqbVtNjOrqdygsghRJqebdr0T6Xlr8pOczcAmKExd4ydj5H0FxpEfgI9MAi)dQqt4gs4va)KQJbMAc3qBOMWnKRC0FeMqmKw8PdFUHmhreT3AmOYXij2YgMHhIFfuebHicNQxbazq1TjKO9wByrmmfralHigMIiAV1yqLJrsSLnmdQUnHiMUH0T6Xld5FabADfGeL)Qrn0MRjCd5kh9hHjedPfF6WNBiv)xPSZUwhtpBLJ(JqePiIO9wJD216y6z9mrKIiI2Bn2zxRJPNHhIFfuebHicNQxbazq1TjKO9wByrmmfralHigMIiAV1yNDToMEguDBcdPB1JxgYgMdvjmGBtyudTGKjCd5kh9hHjedPB1JxgY27itcd42egsl(0Hp3qMJisNiQNnXvaIyQuIibxzT3rMegWTjy4H4xbfrqqvebSeIyQuIO6)kL5q7kcVSJTYr)riIuercUYAVJmjmGBtWWdXVckIGqeZreTC(tWbDXCODfHx2XWdXVckIPjIO9wJ5q7kcVSJr0XUE8setxePiIwo)j4GUyo0UIWl7y4H4xbfrqiIGViMUisreZrer7Tg798Ue2XaJ1ZeXuPer6er0ERXqFoN47qL1ZeX0nKw6T)KQJbMcn0gQrn0c(MWnKRC0FeMqmKUvpEziBVJmjmGBtyiT4th(CdjAV1yz4dHJjo)LG2ZpwptePiI41Wdg4O)mKw6T)KQJbMcn0gQrn0cgMWnKRC0FeMqmKw8PdFUHu9FLYCODfHx2Xw5O)ierkIyoIOEitebfvrmSaRiMkLiI2Bng6Z5eFhQSEMiMUisreZreTC(tWbDXEpVlr7yOYWdXVckIGsebRiMUisreZrePtev)xPSZUwhtpBLJ(JqetLsePter7Tg7SR1X0Z6zIifrKor0Y5pbh0f7SR1X0Z6zIy6gs3QhVmKo0UIWl7mQH2WYeUHCLJ(JWeIH0IpD4ZnKO9wJ9EExc7yGX6zIifrmhre3R14yGXa9veWS5jggkFpVlXd2XaRSJnW1VSSriIPsjI0jIO9wJH4qDyjVj1Gj3pKvkK1ZerkIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIPBiDRE8Yq(EExI2Xq1OgAb5MWnKRC0FeMqmKw8PdFUHu9FLY2pKvQ)s03HkBLJ(JqePiI5iIi(EOI5iIiierqoyfX0nKUvpEzi3pKvQ)s03HQrn0cEmHBix5O)imHyiT4th(CdP6)kLbvogjXw2WSvo6pcrKIiMJiI9JqU8RuMtqazwEVureeIiijIPsjIy)iKl)kL5eeq2vIiOerWaSIy6IifrmhreX3dvmhrebHic(GViMUH0T6Xldju5yKeBzdBudTHrt4gYvo6pctigsl(0Hp3qQ(VszZgWVcqcd42eSvo6pcrKIiA58NGd6I9EExI2XqLHhIFfuebbvreWsyiDRE8YqoBa)kajmGBtyudTHcwt4gYvo6pctigsl(0Hp3qQ(VszZgWVcqcd42eSvo6pcrKIiI2Bn2Sb8RaKWaUnbRNziDRE8Yq(EExI2Xq1OgAdnut4gYvo6pctigsl(0Hp3qQ(Vsz)bU(rirCaexQCDiSvo6pcdPB1JxgY)ax)iKioaIlvUoeJAOn0CnHBix5O)imHyiT4th(CdjAV1yZgWhuYBsa8Cvc7fXWxbW6zIifru9FLYqCOoSK3KAWK7hYkfYw5O)ierkIiAV1yiouhwYBsnyY9dzLcz9mdPB1JxgY5ynaCDpXmQH2qbjt4gYvo6pctigsl(0Hp3qI2Bngu5yKeBzdZ6zIifreT3AmehQdl5nPgm5(HSsHSEMisrer89qfZrerqiIHfynKUvpEzi)diqRRaKO8xnQH2qbFt4gYvo6pctigsl(0Hp3qI2Bn2Sb8bL8MeapxLWErm8vaSEMisreZrev)xPmehQdl5nPgm5(HSsHSvo6pcrKIiMJiI2BngId1HL8MudMC)qwPqwptetLseTC(tWbDXEpVlr7yOYWdXVckIGsebRisrer89qfZrerqrvedJ5kIPsjIWS9VuDmWuiZg4xj)diqRRaerqiI5kIuer0ERXGkhJKylBywptePiIwo)j4GUyVN3LODmuz4H4xbfrqqvebSeIy6IyQuIiDIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIPsjIwo)j4GUy7hYk1Fj67qLHhIFfuebbvreovVcaYGQBtir7T2WIyykIawcrmmfXCfX0nKUvpEziNJ1aW19eZOgAdfmmHBix5O)imHyiT4th(CdjmB)lvhdmfYSb(vY)ac06kareuIyOIifrKorKGRS27itcd42em8A4bdC0FIifrKore3R14yGXMnGpOK3Ka45Qe2lIHVcGnW1VSSriIueXCer6er1)vkdXH6WsEtQbtUFiRuiBLJ(JqetLser7TgdXH6WsEtQbtUFiRuiRNjIPsjIwo)j4GUyVN3LODmuz4H4xbfrqjIGvePiIi(EOI5iIiOOkIHXCfX0nKUvpEziNJ1aW19eZOgAdnSmHBix5O)imHyiT4th(CdPLZFcoOljEUvfrkIyoIiDIiAV1yiouhwYBsnyY9dzLcz9mrKIiI2Bn2zxRJPN1ZeX0nKUvpEziFpVlr7yOAudTHcYnHBix5O)imHyiT4th(CdPLZFcoOljEUvfrkIOnWXadkIGsev)xPSzd4sEtQbtUFiRuiBLJ(JqePiI0jIO9wJD216y6z9mdPB1JxgY3Z7s0ogQg1qBOGht4gYvo6pctigsl(0Hp3qQ(VszZgWL8MudMC)qwPq2kh9hHisrePter7TgdXH6WsEtQbtUFiRuiRNjIuereFpuXCereuufrWaSIifrKoreT3ASzd4dk5njaEUkH9Iy4Ray9mdPB1JxgY3Z7s0ogQg1qBOHrt4gYvo6pctigsl(0Hp3qMJiI71ACmWyZgWhuYBsa8Cvc7fXWxbWg46xw2ieXuPery2(xQogykKzd8RK)beO1vaIiieXCfX0frkIyoIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIuer6er0ERXMnGpOK3Ka45Qe2lIHVcG1ZerkIyoIiAV1yiouhwYBsnyY9dzLcz9mrmvkreX3dvmhrebfvrmmMRiMkLicZ2)s1XatHmBGFL8pGaTUcqebHiMRisrer7TgdQCmsITSHz9mrKIiA58NGd6I9EExI2XqLHhIFfuebbvreWsiIPlIPsjI0jIQ)RugId1HL8MudMC)qwPq2kh9hHiMkLiA58NGd6ITFiRu)LOVdvgEi(vqreeufr4u9kaidQUnHeT3AdlIHPicyjeXWueZvet3q6w94LHCowdKWaUnHrn0MlynHBix5O)imHyiT4th(CdP6)kLD216y6zRC0FeIifru9FLYqCOoSK3KAWK7hYkfYw5O)ierkIiAV1yNDToMEwptePiIO9wJH4qDyjVj1Gj3pKvkK1ZmKUvpEziByouLWaUnHrn0MBOMWnKRC0FeMqmKw8PdFUHeT3AmhAxr4LDSEMH0T6Xld575DjAhdvJAOn3CnHBix5O)imHyiT4th(CdPLZFcoOljEUvfrkIiDIO6)kLH4qDyjVj1Gj3pKvkKTYr)ryiDRE8Yq(EExI2Xq1OgAZfKmHBix5O)imHyiT4th(CdP6)kLD216y6zRC0FeIifrKormhreX3dvmhrebLicsGHisreTC(tWbDXEpVlr7yOYWdXVckIGGQicwrmDdPB1JxgYZUwhtVrn0Ml4Bc3qUYr)rycXqAXNo85gs1)vk7SR1X0Zw5O)ierkIiAV1yNDToMEwptePiI5iIO9wJD216y6z4H4xbfrqiIawcrmmfrWxedtreT3ASZUwhtpdQUnHiMkLiI2Bngu5yKeBzdZ6zIyQuIiDIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIPBiDRE8Yq2WCOkHbCBcJAOnxWWeUH0T6Xld575DjAhdvd5kh9hHjeJAOn3WYeUHCLJ(JWeIH0T6Xldz7DKjHbCBcdPfF6WNBiXRHhmWr)ziT0B)jvhdmfAOnuJAOnxqUjCd5kh9hHjedPfF6WNBiX9AnogyS9dzL6VCGRF)HIVocBGRFzzJqePiI0jIO9wJTFiRu)LdC97pu81rKedT3ASEMisrePtev)xPS9dzL6Ve9DOYw5O)ierkIiDIO6)kLnBa)kajmGBtWw5O)imKUvpEziByouLWaUnHrn0Ml4XeUHCLJ(JWeIH0IpD4ZnKqE)rVIGLN)UE)Kq(NFLYw5O)imKUvpEziB)GbwS3ud5v6W4EMAid1OgAZnmAc3q6w94LH0g4xjdCC(bvd5kh9hHjeJAOfKaRjCd5kh9hHjedPfF6WNBiv)xPSZUwhtpBLJ(JqePiIO9wJD216y6z9mdPB1JxgYgMdvjmGBtyudTGuOMWnKRC0FeMqmKw8PdFUHu9FLYGQRNvsCqBGJbgBLJ(JWq6w94LHeQUEwjXbTbogyg1qliLRjCd5kh9hHjedPfF6WNBiPtev)xPSm8H4VC)qwP(FqLTYr)riIPsjI0jIztzTdp5(HSs9N5w9YpdPB1JxgY5ynqUFiRu)nQHwqcKmHBix5O)imHyiT4th(CdjmB)lvhdmfYSb(vY)ac06kareuIyOgs3QhVmK2a)k5FabADfGrn0csGVjCdPB1JxgY)ac06kajk)vd5kh9hHjeJAOfKadt4gseE(Ram0gQHCLJ(tIWZFfGjedPB1JxgY27itcd42egsl92Fs1XatHgAd1qAXNo85gs8A4bdC0FgYvo6pctig1qlifwMWnKRC0FeMqmKRC0FseE(RamHyiT4th(Cdjcp)qwPmIdQEzNickrmSmKUvpEziBVJmjmGBtyir45VcWqBOg1qlibYnHBir45VcWqBOgYvo6pjcp)vaMqmKUvpEziByouLWaUnHHCLJ(JWeIrn0csGht4gYvo6pctigsl(0Hp3qQ(VszNDToME2kh9hHisrer7Tg7SR1X0Z6zIifreT3ASZUwhtpdpe)kOiccreovVcaYGQBtir7T2WIyykIawcrmmfr0ERXo7ADm9mO62egs3QhVmKnmhQsya3MWOg1qsSM3F1eUH2qnHBix5O)imHyijg0IVm94LHemR0HX9mve5nr06qfYmKUvpEzib9vesyWCSrn0MRjCdjcp)vagAd1qUYr)jr45VcWeIH0T6Xldjm7WNcA)tmmucGD7mKRC0FeMqmQHwqYeUH0T6XldzgxpEzix5O)imHyudTGVjCdPB1JxgYoCYthc0qUYr)rycXOgAbdt4gYvo6pctigsl(0Hp3qMJisNiQ(Vsz7hYk1Fj67qLTYr)riIPlIuer6er9SjUcqePiI0jIztzqLJrK7hYk1FMB1l)erkIyoIimB)lvhdmfYSb(vY)ac06kareeIiijIPsjIQ)RugId1HL8MudMC)qwPq2kh9hHiMkLiI71ACmWyWe0JINNyyOSDdtVKyihCSbU(LLncrmDdPB1JxgY27itcd42eg1qByzc3qUYr)rycXq6w94LHmdFiCmX5Ve0E(ziT4th(CdjDIiAV1yz4dHJjo)LG2ZpwptePiI5iI0jIztzqLJrK7hYk1FMB1l)eXuPery2(xQogykKzd8RK)beO1vaIiierqsePiIO9wJb6RiKaDOYGQBtiIGqeZfSIyQuIiK3F0Riy)Ccjk9YbE7iz)yRC0FeIy6IifrmhreMT)LQJbMcz2a)k5FabADfGiccremeXuPer1)vkdXH6WsEtQbtUFiRuiBLJ(JqetLseX9Anogymyc6rXZtmmu2UHPxsmKdo2ax)YYgHiMkLic59h9kc2pNqIsVCG3os2p2kh9hHiMUH0sV9NuDmWuOH2qnQHwqUjCd5kh9hHjedPfF6WNBiPte1ZM4karKIiMJisNiMnLbvogrUFiRu)zUvV8tetLseHz7FP6yGPqMnWVs(hqGwxbiIGqebjrKIiI2BngOVIqc0HkdQUnHiccrmxWkIPlIueXCery2(xQogykKzd8RK)beO1vaIiierqsetLsev)xPmehQdl5nPgm5(HSsHSvo6pcrmvkre3R14yGXGjOhfppXWqz7gMEjXqo4ydC9llBeIy6gs3QhVmKT3rMegWTjmQHwWJjCdPB1JxgY2HNC)qwP(Bix5O)imHyudTHrt4gs3QhVmKithhBix5O)imHyudTHcwt4gYvo6pctigsl(0Hp3qsNiQ(Vszo0UIWl7yRC0FeIyQuIiAV1yo0UIWl7y9mrmvkr0Y5pbh0fZH2veEzhdpe)kOickremaRH0T6Xldj6Z5eYwhtVrn0gAOMWnKRC0FeMqmKw8PdFUHKoru9FLYCODfHx2Xw5O)ieXuPer0ERXCODfHx2X6zgs3QhVmKOddhoXvag1qBO5Ac3qUYr)rycXqAXNo85gs6er1)vkZH2veEzhBLJ(JqetLser7TgZH2veEzhRNjIPsjIwo)j4GUyo0UIWl7y4H4xbfrqjIGbynKUvpEziBhEOpNtyudTHcsMWnKRC0FeMqmKw8PdFUHKoru9FLYCODfHx2Xw5O)ieXuPer0ERXCODfHx2X6zIyQuIOLZFcoOlMdTRi8YogEi(vqreuIiyawdPB1JxgsVSdQy)Lw)FJAOnuW3eUHCLJ(JWeIH0IpD4ZnK0jIQ)RuMdTRi8Yo2kh9hHiMkLisNiI2BnMdTRi8YowpZq6w94LHe1bK8MuXNnb0OgAdfmmHBiDRE8YqMFWSHLkxhIHCLJ(JWeIrn0gAyzc3qUYr)rycXqAXNo85gslp)kVuwDabQS5tePiI0jI4ETghdmgCJak5nj2rY8sLayoO1a2ax)YYgHisreZrePtev)xPmehQdl5nPgm5(HSsHSvo6pcrmvkreT3AmehQdl5nPgm5(HSsHSEMiMUisreHz7FP6yGPqMnWVs(hqGwxbiIGqebjdPB1JxgYMpPI9c26WJxg1qBOGCt4gYvo6pctigsl(0Hp3qA55x5LYQdiqLnFIifre3R14yGXGBeqjVjXosMxQeaZbTgWg46xw2ierkIyoIiDIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIPsjIO9wJH4qDyjVj1Gj3pKvkK1ZeXuPery2(xQogykKzd8RK)beO1vaIiOOkIGKiMUisreZreTC(tWbDXAhEY9dzL6pdpe)kOickrmxWkIPsjIwo)j4GUyqLJrK7hYk1FgEi(vqreuIyUGvet3q6w94LHS5tQyVGTo84Lrn0gk4XeUHCLJ(JWeIH0IpD4ZnKUvV8tUAi3GIiOeXCfrkIyoIimB)lvhdmfYSb(vY)ac06kareuIyUIyQuIimB)lvhdmfYEpVlrNJiIGseZvet3q6w94LHe3lPB1JxY)GQH8pOklhzgsNpJAOn0WOjCd5kh9hHjedPfF6WNBiPtev)xPmOYXiY9dzL6pBLJ(JqePiIUvV8tUAi3GIiiOkI5AiHk(SQH2qnKUvpEziX9s6w94L8pOAi)dQYYrMHeEfWpP6yGPg1qBUG1eUHCLJ(JWeIH0IpD4ZnKQ)Rugu5ye5(HSs9NTYr)riIuer3Qx(jxnKBqreeufXCnKqfFw1qBOgs3QhVmK4EjDRE8s(hunK)bvz5iZqcNeEfWpP6yGPg1OgYm8SCeuxnHBOnut4gYvo6pctigs3QhVmKZXAGC)qwP(Bijg0IVm94LHe8c8E2UocrC5hMErupKjIAWer3QCSiEqr0Z737O)ygsl(0Hp3qsNiQ(Vszz4dXF5(HSs9)GkBLJ(JWOgAZ1eUHCLJ(JWeIH0T6Xldz7hmWI9MAijg0IVm94LHmSv4ersLJrsSLnSiMHNLJG6Qi2RFqOic5iteDccOic67FreM5GUeriNxmdPfF6WNBiH8(JEfblRd1(p5W9m94fBLJ(JqetLseH8(JEfblp)D9(jH8p)kLTYr)ryudTGKjCd5kh9hHjedPfF6WNBiv)xPmOYXij2YgMTYr)riIueXCerSFeYLFLYCcciZY7LkIGqebjrmvkre7hHC5xPmNGaYUsebLicgGvet3q6w94LHeQCmsITSHnQHwW3eUH0T6Xldz7WtUFiRu)nKRC0FeMqmQHwWWeUHCLJ(JWeIH0IpD4ZnKQ)Ru2(HSs9xI(ouzRC0FeIifreMT)LQJbMcz2a)k5FabADfGiccreKmKUvpEzi3pKvQ)s03HQrn0gwMWnKRC0FeMqmKUvpEziFpVlr7yOAi)RM0syibjdPfF6WNBiPtev)xPS9dzL6Ve9DOYw5O)ierkIimB)lvhdmfYSb(vY)ac06kareeIiijIPsjIO9wJbvogjXw2WSEMHKyql(Y0JxgYqM17WjIGS5dredCOi6IOI987fr9qwsIOgmr0ji4LiM9UDqrmm1GdkIRum9HPiYlrmmemxrSXXIiijIWz5fbuevUi655hHisW7O)azcYMperKxIyw)FMrn0cYnHBix5O)imHyiT4th(CdjDIO6)kLTFiRu)LOVdv2kh9hHisreHz7FP6yGPqMnWVs(hqGwxbiIGIQicsIifrKoreT3AmOYXij2YgM1ZmKUvpEziTb(vY)ac06kaJAOf8yc3q6w94LHmJRhVmKRC0FeMqmQrnKoFMWn0gQjCdPB1JxgsOYXiY9dzL6VHCLJ(JWeIrn0MRjCd5kh9hHjedPfF6WNBir7TgZ6)l)diqRRay4H4xbfrqrvedfSgs3QhVmKJ(j5nPgmju5yeJAOfKmHBix5O)imHyiT4th(CdjAV1yZgWVcqcd42eSEMH0T6Xld5CSgaUUNyg1ql4Bc3q6w94LH0g4xjdCC(bvd5kh9hHjeJAOfmmHBix5O)imHyiT4th(CdP6)kLbvogjXw2WSvo6pcdPB1JxgsOYXij2Yg2OgAdlt4gYvo6pctigs3QhVmKT3rMegWTjmKw8PdFUHeVgEWah9NisreZreZreDRE5NKGRS27itcd42eIiieXCfrkIOB1l)KRgYnOiccQIiijIuerlN)eCqxSm8HWXeN)sq75hdpe)kOiccrm0WsePiIwE(vEPSAwm)5ycrKIisNiMnLbvogrUFiRu)zUvV8tetLseDRE5NKGRS27itcd42eIiieXqfrkIOB1l)KRgYnOickQIi4lIuer6eXSPmOYXiY9dzL6pZT6LFIifru9FLYqCOoSK3KAWK7hYkfYw5O)ieX0fXuPeXCerCVwJJbgdMGEu88eddLTBy6Led5GJnW1VSSriIuer6eXSPmOYXiY9dzL6pZT6LFIy6Iy6gsl92Fs1XatHgAd1OgAb5MWnKRC0FeMqmKw8PdFUHKor0T6LFscUYAVJmjmGBtiIuer6eXSPmOYXiY9dzL6pZT6LFIifrmhru9FLYqCOoSK3KAWK7hYkfYw5O)ieXuPerCVwJJbgdMGEu88eddLTBy6Led5GJnW1VSSriIPBiDRE8Yq2Ehzsya3MWOgAbpMWnKRC0FeMqmKw8PdFUHu9FLYMnGFfGegWTjyRC0FeIifreX3dvmhrebfvrmSaRisreZreX9AnogySzd4dk5njaEUkH9Iy4RaydC9llBeIifreT3ASzd4dk5njaEUkH9Iy4Ray9mrmvkrKore3R14yGXMnGpOK3Ka45Qe2lIHVcGnW1VSSriIPBiDRE8YqoBa)kajmGBtyudTHrt4gYvo6pctigsl(0Hp3qQ(Vszo0UIWl7yRC0FeIifrmhrKormBkdQCmIC)qwP(ZCRE5NiMUisreZrePtev)xPSZUwhtpBLJ(JqetLsePter7Tg7SR1X0Z6zIifrKor0Y5pbh0f7SR1X0Z6zIy6gs3QhVmKo0UIWl7mQH2qbRjCd5kh9hHjedPfF6WNBiv)xPS)ax)iKioaIlvUoe2kh9hHH0T6Xld5FGRFesehaXLkxhIrn0gAOMWnKRC0FeMqmKw8PdFUHeMT)LQJbMcz2a)k5FabADfGiccre8frkIiAV1yiouhwYBsnyY9dzLcz9mrKIiI47HkMJiIGqebdWAiDRE8YqAd8RK)beO1vag1qBO5Ac3qUYr)rycXqAXNo85gsCVwJJbgB2a(GsEtcGNRsyVig(ka2ax)YYgHisrePter7TgB2a(GsEtcGNRsyVig(kawpZq6w94LHCowdKWaUnHrn0gkizc3qUYr)rycXqAXNo85gscUYAVJmjmGBtWWdXVckIuery2(xQogykKzd8RK)beO1vaIiierWxePiI5iI0jIztzqLJrK7hYk1FMB1l)eX0frkIyoIiAV1yVN3LWogySEMisrePter7TgdXH6WsEtQbtUFiRuiRNjIuer1)vkdXH6WsEtQbtUFiRuiBLJ(Jqet3q6w94LH898UeTJHQrn0gk4Bc3qUYr)rycXqAXNo85gsy2(xQogykKzd8RK)beO1vaIiOOkI5kIuer6erCVwJJbgB2a(GsEtcGNRsyVig(ka2ax)YYgHisreZrev)xPmehQdl5nPgm5(HSsHSvo6pcrKIiI47HkMJiIGIQicgGvePiI0jIO9wJH4qDyjVj1Gj3pKvkK1ZeX0nKUvpEziNJ1aW19eZOgAdfmmHBix5O)imHyiT4th(CdjbxzT3rMegWTjy4H4xbfrkIiAV1yVN3LWogySEMisrer7TgldFiCmX5Ve0E(X6zgs3QhVmKVN3LODmunQH2qdlt4gYvo6pctigsl(0Hp3qsWvw7DKjHbCBcgEi(vqrKIicZ2)s1XatHmBGFL8pGaTUcqebHic(Iifre3R14yGXGjOhfppXWqz7gMEjXqo4ydC9llBeIifreT3AS3Z7syhdmwptePiIQ)RugId1HL8MudMC)qwPq2kh9hHisrePter7TgdXH6WsEtQbtUFiRuiRNjIuereFpuXCereuufrWaSgs3QhVmKVN3LODmunQH2qb5MWnKRC0FeMqmKw8PdFUHKGRS27itcd42em8q8RGIifrmhrmhreMT)LQJbMcz2a)k5FabADfGiccre8frkIiUxRXXaJbtqpkEEIHHY2nm9sIHCWXg46xw2ierkIO6)kLH4qDyjVj1Gj3pKvkKTYr)riIPlIPsjI5iIQ)RugId1HL8MudMC)qwPq2kh9hHisrer89qfZrerqrvebdWkIuer6er0ERXqCOoSK3KAWK7hYkfY6zIifrmhrKore3R14yGXMnGpOK3Ka45Qe2lIHVcGnW1VSSriIPsjIO9wJnBaFqjVjbWZvjSxedFfaRNjIPlIuer6erCVwJJbgdMGEu88eddLTBy6Led5GJnW1VSSriIPlIPBiDRE8Yq(EExI2Xq1OgAdf8yc3qUYr)rycXqAXNo85gscUYAVJmjmGBtWWdXVckIuery2(xQogykKzd8RK)beO1vaIivre8frkIiUxRXXaJbtqpkEEIHHY2nm9sIHCWXg46xw2ierkIiAV1yVN3LWogySEMisrev)xPmehQdl5nPgm5(HSsHSvo6pcrKIisNiI2BngId1HL8MudMC)qwPqwptePiIi(EOI5iIiOOkIGbynKUvpEziFpVlr7yOAudTHggnHBix5O)imHyiT4th(CdjmB)lvhdmfYSb(vY)ac06kareuufXCnKUvpEziNJ1aW19eZOgAZfSMWnKRC0FeMqmKw8PdFUHeT3AmOYXij2YgMHhIFfuebHicsIyykIawcrmmfr0ERXGkhJKylByguDBcdPB1JxgsBGFL8pGaTUcWOgAZnut4gYvo6pctigsl(0Hp3qI2Bn275DjSJbgRNjIuery2(xQogykKzd8RK)beO1vaIiierWxePiI5iI0jIztzqLJrK7hYk1FMB1l)eX0frkIibxzT3rMegWTjy6ztCfGH0T6Xld575DjAhdvJAOn3CnHBix5O)imHyiT4th(CdP6)kLTFiRu)LOVdv2kh9hHisreHz7FP6yGPqMnWVs(hqGwxbiIGqebdrKIiMJisNiMnLbvogrUFiRu)zUvV8tet3q6w94LHC)qwP(lrFhQg1qBUGKjCd5kh9hHjedPfF6WNBiv)xPmhAxr4LDSvo6pcdPB1JxgY3Z7s05ig1qBUGVjCdPB1JxgsBGFL8pGaTUcWqUYr)rycXOgAZfmmHBix5O)imHyix5O)Ki88xbycXqAXNo85gs0ERXEpVlHDmWy9mrKIiA58NGd6sINBvdPB1JxgY3Z7s0ogQgseE(Ram0gQrn0MByzc3qIWZFfGH2qnKRC0FseE(RamHyiDRE8Yq2Ehzsya3MWqAP3(tQogyk0qBOgsl(0Hp3qIxdpyGJ(ZqUYr)rycXOgAZfKBc3qIWZFfGH2qnKRC0FseE(RamHyiDRE8Yq2WCOkHbCBcd5kh9hHjeJAudjCs4va)KQJbMAc3qBOMWnKUvpEziHkhJi3pKvQ)gYvo6pctig1qBUMWnKRC0FeMqmKw8PdFUHeT3AmR)V8pGaTUcGHhIFfuebfvrmuWAiDRE8Yqo6NK3KAWKqLJrmQHwqYeUHCLJ(JWeIH0IpD4ZnKQ)Ru2zxRJPNTYr)riIuer0ERXo7ADm9SEMisrer7Tg7SR1X0ZWdXVckIGqeHt1RaGmO62es0ERnSigMIiGLqedtreT3ASZUwhtpdQUnHisrer7Tgd0xrib6qLbv3MqebHigk4Xq6w94LHSH5qvcd42eg1ql4Bc3qUYr)rycXqAXNo85gs1)vkB)qwP(lrFhQSvo6pcdPB1JxgY9dzL6Ve9DOAudTGHjCd5kh9hHjedPfF6WNBiv)xPmOYXij2YgMTYr)ryiDRE8YqcvogjXw2Wg1qByzc3qUYr)rycXqAXNo85gs1)vkB2a(vasya3MGTYr)riIuerlN)eCqxS3Z7s0ogQm8q8RGIiiOkIawcrKIicZ2)s1XatHmBGFL8pGaTUcqebHiMRiMkLiI47HkMJiIGIQigwGvePiIWS9VuDmWuiZg4xj)diqRRaerqrveZvePiI5iI0jI4ETghdm2Sb8bL8MeapxLWErm8vaSbU(LLncrmvkreT3ASzd4dk5njaEUkH9Iy4Ray9mrmDrmvkreMT)LQJbMcz2a)k5FabADfGiccrmxrKIiI2BngOVIqc0HkdQUnHickQIyOGhrKIiMJisNiI71ACmWyZgWhuYBsa8Cvc7fXWxbWg46xw2ieXuPer0ERXMnGpOK3Ka45Qe2lIHVcG1ZeX0frkIiIVhQyoIickQIyybwdPB1JxgYzd4xbiHbCBcJAOfKBc3qUYr)rycXqAXNo85gYCer0ERXa9vesGouzq1TjerqiIHcEerkIiDIiAV1yOpNt8DOY6zIy6IyQuIiAV1yVN3LWogySEMH0T6Xld575DjAhdvJAOf8yc3qUYr)rycXqAXNo85gs1)vkB2a(vasya3MGTYr)riIuer0ERXMnGFfGegWTjy9mrKIicZ2)s1XatHmBGFL8pGaTUcqebHiMRH0T6Xld575DjAhdvJAOnmAc3qUYr)rycXqAXNo85gs1)vkB2a(vasya3MGTYr)riIuer0ERXMnGFfGegWTjy9mrKIicZ2)s1XatHmBGFL8pGaTUcqebfvrmxdPB1JxgY5ynaCDpXmQH2qbRjCd5kh9hHjedPfF6WNBir7TgdQCmsITSHz9mdPB1JxgY)ac06kajk)vJAOn0qnHBix5O)imHyiT4th(CdjAV1yZgWhuYBsa8Cvc7fXWxbW6zgs3QhVmKZXAa46EIzudTHMRjCd5kh9hHjedPfF6WNBiHz7FP6yGPqMnWVs(hqGwxbiIGqeZvePiIi(EOI5iIiOOkIHfyfrkIyoIiAV1yG(kcjqhQmO62eIiieXCbRiMkLiI47HkMJiIGsedJGvetxetLseZreX9AnogySzd4dk5njaEUkH9Iy4RaydC9llBeIifrKoreT3ASzd4dk5njaEUkH9Iy4Ray9mrmDdPB1JxgY5ynqcd42eg1qBOGKjCd5kh9hHjedPfF6WNBiZreHz7FP6yGPqMnWVs(hqGwxbiIGsedvetxePiI5iI0jIeCL1Ehzsya3MGHxdpyGJ(tet3q6w94LHCowdax3tmJAOnuW3eUHCLJ(JWeIH0IpD4ZnKUvV8tUAi3GIiOeXqfrkIy2ugu5ye5(HSs9N5w9YprKIiI2Bng6Z5eFhQSEMH0T6XldPnWVs(hqGwxbyudTHcgMWnKRC0FeMqmKw8PdFUHmBkdQCmIC)qwP(ZCRE5Nisrer7Tgd95CIVdvwpZq6w94LH8pGaTUcqIYF1OgAdnSmHBix5O)imHyiT4th(CdjAV1yo0UIWl7y9mdPB1JxgY3Z7s0ogQg1qBOGCt4gYvo6pctigsl(0Hp3qA58NGd6sINBvdPB1JxgY3Z7s0ogQg1qBOGht4gYvo6pctigsl(0Hp3qA58NGd6sINBvrKIiAdCmWGIiOer1)vkB2aUK3KAWK7hYkfYw5O)imKUvpEziFpVlr7yOAudTHggnHBix5O)imHyiT4th(CdP6)kLD216y6zRC0FeIifreT3ASZUwhtpRNziDRE8Yq2WCOkHbCBcJAOnxWAc3q6w94LH0g4xjdCC(bvd5kh9hHjeJAOn3qnHBix5O)imHyiT4th(CdjK3F0Riy55VR3pjK)5xPSvo6pcdPB1JxgY2pyGf7n1qELomUNPgYqnQH2CZ1eUHCLJ(JWeIH0IpD4ZnKQ)RuguD9SsIdAdCmWyRC0Fegs3QhVmKq11ZkjoOnWXaZOgAZfKmHBix5O)imHyiT4th(CdjDIO6)kLLHpe)L7hYk1)dQSvo6pcrmvkru9FLYYWhI)Y9dzL6)bv2kh9hHisreZrePteZMYGkhJi3pKvQ)m3Qx(jIPBiDRE8YqohRbY9dzL6Vrn0Ml4Bc3qUYr)rycXqAXNo85gs3Qx(jxnKBqreuIyOIifrmhreMT)LQJbMcz2a)k5FabADfGickrmurmvkreMT)LQJbMczVN3LOZrerqjIHkIPBiDRE8YqAd8RK)beO1vag1qBUGHjCdPB1JxgY)ac06kajk)vd5kh9hHjeJAOn3WYeUHeHN)kadTHAix5O)Ki88xbycXq6w94LHS9oYKWaUnHH0sV9NuDmWuOH2qnKw8PdFUHeVgEWah9NHCLJ(JWeIrn0Mli3eUHCLJ(JWeIHCLJ(tIWZFfGjedPfF6WNBir45hYkLrCq1l7erqjIHLH0T6Xldz7DKjHbCBcdjcp)vagAd1OgAZf8yc3qIWZFfGH2qnKRC0FseE(RamHyiDRE8Yq2WCOkHbCBcd5kh9hHjeJAuJAuJAma]] )

end
