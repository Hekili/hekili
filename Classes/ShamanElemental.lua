-- ShamanElemental.lua
-- 09.2020

-- TODOs:
-- Legendaries
-- Covenant abilities (1/4)
-- Soulbinds (?)
-- Conduits (?)

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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
            duration = 12,
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
            duration = 18,
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
            end,
        },

        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = 60,
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
            end,
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
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental", 30 )
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
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 237579,

            handler = function ()
                applyDebuff( "target", "hex" )
            end,
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
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental", 30 )
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
            cooldown = 60,
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
            cast = 1.5,
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
            cast = 3,
            channeled = true,
            cooldown = 120,
            gcd = "spell",

            spend = 0.075,
            spendType = "mana",

            startsCombat = true,
            texture = 3636849,

            toggle = "essences",
            nobuff = "fae_transfusion",

            handler = function ()
                applyBuff( "fae_transfusion" )
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

            if not Hekili.DB.profile.specs[ spec.id ].cycle then
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

    spec:RegisterPack( "Elemental", 20200913, [[dGKXCaqicKhraTjji9jcGyusaDkjaVsImlcXTiKODPk)su1WiuDmjQLPG8mcuttbLRrOyBsq9ncjzCkOQZPGkRtcu9ocjuZJqQUNcTpLuDqcaluu5HsGYfjKYgjasFuceojHKALe0mjaQUjHeyNIWqjKqwkHe0tPyQIORsau(QeiAVc)vPgSKomQfRQEmKjROld2SO8zrA0i40s9ALKzJ0Tr0UP63QmCe64sqSCk9COMoPRReBxc9DLugVeiDEcLwpbO5Ra7NOJYrYWmzfIedj(qIl(WvwWVYcU8WeZWcJkwIqyiYOvCkegNjHWiAuGeCLPHHilw6XZizyW3IfbHHGQeXf885tBLWY)HoY84MCHYAFoYYzAECtIYhM)stvrTh)WmzfIedj(qIl(WvwWVYcU8WklMWGjcOiXqfEOWqONtWJFyMagfgbkRIgfibxzQSAiWKSlfkqz1aevG8dwzTSGfrwhs8HepmeTxwtHWiqzv0Oaj4ktLvdbMKDPqbkRgGOcKFWkRLfSiY6qIpK4sHsHcuwlyeypfWfCPqPqbkRms7ZXpIwaDKFwhZOmELuOaLvgP954hrlGoYpRLgZND3ukuGYkJ0(C8JOfqh5N1sJ55LusWvw7ZLcfOSACMiMWPYQL7PS(xYYGPSIvwXY6hYoliROJ8ZQS(H02XYk7tzLOfeLepvBpvwBSSophEsHcuwzK2NJFeTa6i)SwAmp2zIycNUXkRyPqgP954hrlGoYpRLgZt7ucQ3E6gtOb6ukKrAFo(r0cOJ8ZAPX8lyy3kqkIZKWilGycSLX7SZ19LTjERbwPqbkRcWWGSA0ZsUcaIGvwjAb0r(zvwxCkGXYk(ibzLNtSSUwtPYkMiVMlR478NuiJ0(C8JOfqh5N1sJ5X6zjxbarWksNnQmfC9H1ZsUcaIG9bo)PWSqlql3ZnueC9XZj(HUfxfDbpyGL75gkcU(45e)AFDXiEbifYiTph)iAb0r(zT0yEIN2NlfYiTph)iAb0r(zT0yEGcKGRmD)PmwfPZgvMcU(akqcUY09NYy9bo)PWukKrAFo(r0cOJ8ZAPX8uUiV)lwSksNnkiLPGRpGcKGRmD)PmwFGZFkmLcLcfOSkAfuaTOWuwHIGvSYQ2KGSQeazLr6zL1glRCrUP8NcpPqbkRfmgRYAo6Dt6cwLvs2xykvSYANjRkbqwfaciyBfK1KwUvzva4iaRwMkRIcb85SJazTXYkrlGbxFsHms7ZXJF6Dt6cwfPZgzbeSTcp2rawTmDBb85SJGh48NctPqbkRIAxuIoYpRYkXt7ZL1glReTqgybxBMsfRSsBFfmLv9KvLaiRfelSD2SlRxMSkaeqWEkbrK1fNcySSIoYpRY6AnLkRGpLvmHZQuX(KczK2NJlnMN4P95I0zJqbLiGuyUrh5N1nf8uLGOuBsq0lS4dgGUJoV18x6cBNn77lBZciypLWZcKC7yrxWIlfkqzvu7kyTlevz9YKveJv8tkKrAFoU0y(1AFUXea2kfYiTphxAm)cg2TcKyPqgP954sJ5ZAlSbkqcUYuPqgP954sJ5X6zj3afibxzQuiJ0(CCPX8F6DZD2IvSI0zJcszk46JXiWNSJGh48NcZbd(lzzpgJaFYocElehmaDhDER5pgJaFYocEwGKBhVUyexkKrAFoU0y(pyXGDv7PI0zJcszk46JXiWNSJGh48NcZbd(lzzpgJaFYocEleLczK2NJlnMpRTWNE3uKoBuqktbxFmgb(KDe8aN)uyoyWFjl7Xye4t2rWBH4GbO7OZBn)Xye4t2rWZcKC741fJ4sHms7ZXLgZZocWQLPBetPI0zJcszk46JXiWNSJGh48NcZbd(lzzpgJaFYocElehmaDhDER5pgJaFYocEwGKBhVUyexkKrAFoU0y(IaMiy36PaPuiJ0(CCPX8eTn5zNnt3RXfbPqgP954sJ5ZyyRw2Xzl4(CPqgP954sJ5re423eyBraRI0zJms7IWgCGSb86LLczK2NJlnM)ZP7lBR2gTclsNnkiLPGRpgJaFYocEGZFkmhmqq)LSShJrGpzhbVfIsHms7ZXLgZdicx7PBmHdTsKoBKKbkwTh56JfwCPqgP954sJ5Tl(MrAF(M2yveNjHr(ar6SrgPDrydoq2aE9Hk0ceteO0TY2uqXpebU9nTtjOE7PRp0GbyIaLUv2Mck(r5I8(dm56dvasHms7ZXLgZBx8nJ0(8nTXQiotcJ42tPWwzBkOsHsHcuwffSq1wwv2McQSYiTpxwjA7Z2QyLvAJvPqgP954hFWiwpl5kaicwr6SrLPGRpSEwYvaqeSpW5pfMsHms7ZXp(GsJ5zmc8j7iqkKrAFo(XhuAmpTlKLEUj5usERNcKsHms7ZXp(GsJ5b2QekKfEfifYiTph)4dknMNYf59hysr6SrLPGRpgJaFYocEGZFkmLczK2NJF8bLgZJiWTVPDkb1BpvkKrAFo(XhuAmpwzTr7zJreyBkifYiTph)4dknMNYf59FXIvriVITNowwKoBuzk46JXiWNSJGh48NctPqgP954hFqPX8zuMe2ychALiKxX2thllIY2uq3D2OfYSaMa)PGuiJ0(C8JpO0y(m7H1nMWHwjc5vS90XYsHsHcuwnTNsbznjBtbvwfaiTpxwffz7Z2QyLvb4nwLcfOSkAoEXcYQauJS2yzLrAxeK1fNcySSk2BrwjWfbzT8WK1ZkRKNfKvSYOvyz9YK1cY2NYAbXcwL1m7rkRg9SKYQOrbsWvM(K1cu0MPGSIymuWL1fIOJS9uzvaGrY6FrLvgPDrqwnIMOyzDEUaevwlaPqgP954hU9ukSv2Mc6ygLjHnMWHwjIY2uq3D2ybkiTrRApDWG5PVmktcBmHdT6zbsUDSOpMIMfqHkO)sw2dVytH9LTjERb23crPqgP954hU9ukSv2McAPX8mgb(KDeifYiTph)WTNsHTY2uqlnMhOaj4kt3FkJvPqgP954hU9ukSv2McAPX8y9SKRaGiyLczK2NJF42tPWwzBkOLgZt7czPNBsoLK36PaPuiJ0(C8d3Ekf2kBtbT0yEANsq92t3ugJpPqgP954hU9ukSv2McAPX8uUiV)lwSkfYiTph)WTNsHTY2uqlnMpZEyDJjCOvI0zJ)LSSxJGSfRyFleLczK2NJF42tPWwzBkOLgZ3iiBXkwPqgP954hU9ukSv2McAPX8aBvcBmHdTskKrAFo(HBpLcBLTPGwAmpwzTr7zJreyBkifYiTph)WTNsHTY2uqlnMN2PeuV909)OQuiJ0(C8d3Ekf2kBtbT0y(mktcBmHdTseYRy7PJLfrzBkO7oB0czwatG)uqkKrAFo(HBpLcBLTPGwAmFgLjHnMWHwjc5vS90XYI0zJKxrGeC9nBSYocwVWsHms7ZXpC7PuyRSnf0sJ5ZShw3ychALiKxX2thlhMIGf3Nhjgs8Hex8HVSGFLdZAS1BpfhgrnjXZQWuwhMSYiTpxwPnwXpPWWqBSIJKHb3Ekf2kBtbnsgjkhjdd48NcZixyq2wbBZHPaLvbjRAJw1EQSoyGSop9LrzsyJjCOvplqYTJLvrFuwtrtzTaK1cvwfKS(xYYE4fBkSVSnXBnW(wigggP95HjJYKWgt4qRcnsmuKmmms7ZddJrGpzhbHbC(tHzKl0iHGJKHHrAFEyakqcUY09NYynmGZFkmJCHgjgwKmmms7Zddwpl5kaic2Wao)PWmYfAKqmrYWWiTppm0Uqw65MKtj5TEkqggW5pfMrUqJefosgggP95HH2PeuV90nLX4lmGZFkmJCHgjevrYWWiTppmuUiV)lwSggW5pfMrUqJedFKmmGZFkmJCHbzBfSnhM)sw2Rrq2IvSVfIHHrAFEyYShw3ychAvOrIHlsgggP95HPrq2IvSHbC(tHzKl0irzXJKHHrAFEya2Qe2ychAvyaN)uyg5cnsuUCKmmms7ZddwzTr7zJreyBkegW5pfMrUqJeLhksgggP95HH2PeuV909)OAyaN)uyg5cnsuwWrYWao)PWmYfgW5pf2KxX2tJCHHrAFEyYOmjSXeo0QWGSTc2MdJfYSaMa)PqyiVITNgjkhAKO8WIKHbC(tHzKlmGZFkSjVITNg5cdY2kyBomKxrGeC9nBSYocK11L1chggP95HjJYKWgt4qRcd5vS90ir5qJeLftKmmKxX2tJeLdd48NcBYRy7PrUWWiTppmz2dRBmHdTkmGZFkmJCHgAy4dIKrIYrYWao)PWmYfgKTvW2CyuMcU(W6zjxbarW(aN)uygggP95HbRNLCfaebBOrIHIKHHrAFEyymc8j7iimGZFkmJCHgjeCKmmms7ZddTlKLEUj5usERNcKHbC(tHzKl0iXWIKHHrAFEya2QekKfEfegW5pfMrUqJeIjsggW5pfMrUWGSTc2MdJYuW1hJrGpzhbpW5pfMHHrAFEyOCrE)bMm0irHJKHHrAFEyqe4230oLG6TNggW5pfMrUqJeIQizyyK2NhgSYAJ2ZgJiW2uimGZFkmJCHgjg(izyaN)uyg5cd48NcBYRy7PrUWGSTc2MdJYuW1hJrGpzhbpW5pfMHHrAFEyOCrE)xSynmKxX2tJeLdnsmCrYWao)PWmYfgW5pf2KxX2tJCHHrAFEyYOmjSXeo0QWGSTc2MdJfYSaMa)PqyiVITNgjkhAKOS4rYWqEfBpnsuomGZFkSjVITNg5cdJ0(8WKzpSUXeo0QWao)PWmYfAOHzcz8cvJKrIYrYWao)PWm(HbzBfSnhgwabBRWJDeGvlt3waFo7i4bo)PWmmms7ZdZNE3KUG1qJedfjdd48NcZixyq2wbBZHbkOebKcZn6i)SUPGNQeKvrPSQnjiRIUSwyXL1bdKv0D05TM)sxy7SzFFzBwab7PeEwGKBhlRIUSkyXddJ0(8Wq80(8qJecosgggP95HzT2NBmbGTHbC(tHzKl0iXWIKHHrAFEywWWUvGehgW5pfMrUqJeIjsgggP95HjRTWgOaj4ktdd48NcZixOrIchjddJ0(8WG1ZsUbkqcUY0Wao)PWmYfAKqufjdd48NcZixyq2wbBZHrqYQYuW1hJrGpzhbpW5pfMY6GbY6Fjl7Xye4t2rWBHOSoyGSIUJoV18hJrGpzhbplqYTJL11LvXiEyyK2NhMp9U5oBXk2qJedFKmmGZFkmJCHbzBfSnhgbjRktbxFmgb(KDe8aN)uykRdgiR)LSShJrGpzhbVfIHHrAFEy(Gfd2vTNgAKy4IKHbC(tHzKlmiBRGT5Wiizvzk46JXiWNSJGh48NctzDWaz9VKL9ymc8j7i4Tquwhmqwr3rN3A(JXiWNSJGNfi52XY66YQyepmms7ZdtwBHp9UzOrIYIhjdd48NcZixyq2wbBZHrqYQYuW1hJrGpzhbpW5pfMY6GbY6Fjl7Xye4t2rWBHOSoyGSIUJoV18hJrGpzhbplqYTJL11LvXiEyyK2Nhg2rawTmDJykn0ir5YrYWWiTppmfbmrWU1tbYWao)PWmYfAKO8qrYWWiTppmeTn5zNnt3RXfHWao)PWmYfAKOSGJKHHrAFEyYyyRw2Xzl4(8Wao)PWmYfAKO8WIKHbC(tHzKlmiBRGT5WWiTlcBWbYgWY66YA5WWiTppmicC7BcSTiG1qJeLftKmmGZFkmJCHbzBfSnhgbjRktbxFmgb(KDe8aN)uykRdgiRcsw)lzzpgJaFYocEleddJ0(8W8509LTvBJwHdnsuUWrYWao)PWmYfgKTvW2CyizGIv7rkRRpkRfw8WWiTppmaIW1E6gt4qRcnsuwufjdd48NcZixyq2wbBZHHrAxe2GdKnGL11L1HK1cvwlqzfteO0TY2uqXpebU9nTtjOE7PY66Y6qY6GbYkMiqPBLTPGIFuUiV)atkRRlRdjRfqyyK2Nhg7IVzK2NVPnwddTX62zsim8bHgjkp8rYWao)PWmYfggP95HXU4BgP95BAJ1WqBSUDMecdU9ukSv2McAOHggIwaDKFwJKrIYrYWWiTppm0oLG6TNUXeAGodd48NcZixOrIHIKHbC(tHzKlmotcHHfqmb2Y4D256(Y2eV1aByyK2NhgwaXeylJ3zNR7lBt8wdSHgjeCKmmGZFkmJCHbzBfSnhgLPGRpSEwYvaqeSpW5pfMYAHkRfOSA5EUHIGRpEoXp0T4QSk6YQGL1bdKvl3ZnueC9XZj(1USUUSkgXL1cimms7Zddwpl5kaic2qJedlsgggP95HH4P95HbC(tHzKl0iHyIKHbC(tHzKlmiBRGT5WOmfC9buGeCLP7pLX6dC(tHzyyK2NhgGcKGRmD)Pmwdnsu4izyaN)uyg5cdY2kyBomcswvMcU(akqcUY09NYy9bo)PWmmms7ZddLlY7)IfRHgAOHHxucNnmMMCHYAFEbZYzAOHgb]] )

end
