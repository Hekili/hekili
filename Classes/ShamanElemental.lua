-- ShamanElemental.lua
-- 07.2020

-- TODOs:
-- Legendaries
-- Covenant abilities
-- sould binds (?)
-- conduits (?)

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( "player" ) == "SHAMAN" then
    local spec = Hekili:NewSpecialization( 262 )

    spec:RegisterResource( Enum.PowerType.Maelstrom )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        earthen_rage = 22356, -- 170374
        echo_of_the_elements = 22357, -- 333919
        elemental_blast = 22358, -- 117014

        aftershock = 23108, -- 273221
        echoing_shock = 23460, -- 320125
        totem_mastery = 23190, -- 333925

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
            duration = 8,
            max_stack = 1,
        },

        bloodlust = {
            id = 2825,
            duration = 40,
            type = "Magic",
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

        frost_shock = {
            id = 196840,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        fulmination = {
            id = 190493,
            duration = 30,
            max_stack = 8,
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
        },

        master_of_the_elements = {
            id = 260734,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        seismic_thunder = {
            id = 319343,
            duration = 12,
            max_stack = 5,
        },

        spiritwalkers_grace = {
            id = 79206,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        spirit_wolf = {
            id = 260881,
            duration = 3600,
            max_stack = 4,
        },

        static_charge = {
            id = 265046,
            duration = 3,
            type = "Magic",
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

        totem_mastery = {
            duration = 15,
            generate = function ()
            end,
        },

        wind_gust = {
            id = 263806,
            duration = 30,
            max_stack = 20
        },


        -- Azerite Powers
        ancestral_resonance = {
            id = 277943,
            duration = 15,
            max_stack = 1,
        },

        tectonic_thunder = {
            id = 286976,
            duration = 15,
            max_stack = 1,
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


    local function natural_harmony( elem1, elem2, elem3 )
        if not azerite.natural_harmony.enabled then return end

        if elem1 then applyBuff( "natural_harmony_" .. elem1 ) end
        if elem2 then applyBuff( "natural_harmony_" .. elem2 ) end
        if elem3 then applyBuff( "natural_harmony_" .. elem3 ) end
    end

    setfenv( natural_harmony, state )

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
            gcd = "spell",

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
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.tectonic_thunder.up or buff.stormkeeper.up ) and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            nobuff = "ascendance",
            bind = "lava_beam",

            startsCombat = true,
            texture = 136015,

            handler = function ()
                removeBuff( "master_of_the_elements" )

                if active_enemies > 1 then
                    addStack( "seismic_thunder", nil, 1)
                end

                if buff.stormkeeper.up then
                    if active_enemies > 1 then
                        addStack( "seismic_thunder", nil, min( 5, active_enemies ))
                    end
                    removeStack( "stormkeeper" )
                else
                    removeBuff( "tectonic_thunder" )
                end

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

        door_of_shadows = {
            id = 300728,
            cast = function () return 1.5 * haste end,
            cooldown = 60,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 3586270,

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


            startsCombat = true,
            texture = 136026,

            handler = function ()
                if talent.surge_of_power.enabled and buff.fulmination.stack >= 6 then
                    applyBuff( "surge_of_power" )
                end

                removeBuff( "fulmination" )
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
            cast = function ()
                return (1 - 0.2 * buff.seismic_thunder.stack) * 3 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            -- TODO: add echoes of the great sundering legendary buff
            --spend = function () return buff.echoes_of_the_great_sundering.up and 0 or 60 end,

            startsCombat = true,
            texture = 451165,

            handler = function ()
                -- TODO: recycle buff
                --removeBuff( "echoes_of_the_great_sundering" )
                removeBuff( "master_of_the_elements" )
                removeBuff( "seismic_thunder" )
            end,
        },

        echoing_shock = {
            id = 320125,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1603013,

            handler = function ()
                applyBuff( "echoing_shock" )
            end,
        },

        elemental_blast = {
            id = 117014,
            cast = function () return 2 * haste end,
            cooldown = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 651244,

            handler = function ()
                applyBuff( "elemental_blast" )
                if talent.surge_of_power.enabled and buff.fulmination.stack >= 6 then
                    applyBuff( "surge_of_power" )
                end

                removeBuff( "fulmination" )
                removeBuff( "master_of_the_elements" )
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.9 or 1 ) * 150 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.9 or 1 ) * 150 end,
            gcd = "spell",

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
            end,
        },

        frost_shock = {
            id = 196840,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 135849,

            handler = function ()
                removeBuff( "master_of_the_elements" )
                applyDebuff( "target", "frost_shock" )

                if buff.icefury.up then
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

        healing_surge = {
            id = 8004,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.23,
            spendType = "mana",

            startsCombat = false,
            texture = 136044,

            handler = function ()
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

            startsCombat = true,
            texture = 135855,

            handler = function ()
                removeBuff( "master_of_the_elements" )
                applyBuff( "icefury", 15, 4 )
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
                if active_enemies > 1 then
                    addStack( "seismic_thunder", nil, 1)
                end

                if buff.stormkeeper.up then
                    if active_enemies > 1 then
                        addStack( "seismic_thunder", nil, min( 5, active_enemies ))
                    end
                    removeStack( "stormkeeper" )
                end
            end,
        },

        lava_burst = {
            id = 51505,
            cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
            charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
            cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            gcd = "spell",


            startsCombat = true,
            texture = 237582,

            handler = function ()
                removeBuff( "lava_surge" )
                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end
                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
                end
            end,
        },

        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136048,

            handler = function ()
                addStack("fulmination", nil, 1)

                removeBuff( "master_of_the_elements" )

                if buff.stormkeeper.up then
                    addStack("fulmination", nil, 1)
                    removeStack( "stormkeeper" )
                end

                if buff.surge_of_power.up then
                    addStack("fulmination", nil, 1)
                    removeBuff( "surge_of_power" )
                end

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
                applyDebuff( "target", "lightning_lasso" )
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

            handler = function ()
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

            handler = function ()
            end,
        },

        spiritwalkers_grace = {
            id = 79206,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 451170,

            handler = function ()
            end,
        },

        storm_elemental = {
            id = 192249,
            cast = 0,
            charges = 1,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 150 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 150 end,
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

            talent = "stormkeeper",
            toggle = "cooldowns",

            startsCombat = false,
            texture = 839977,

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

        totem_mastery = {
            id = 333925,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "totem_mastery",
            toggle = "cooldowns",
            -- essential = true,

            startsCombat = false,
            texture = 511726,

            handler = function ()
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
            end,
        },

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]

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

            talent = "wind_rush_totem",

            startsCombat = false,
            texture = 538576,

            handler = function ()
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

    spec:RegisterPack( "Elemental", 20200726, [[dOuXWaqikbpsIytQiXNursAuufYPKiXROknliQBbr0UuQFrjnmjQogvrlJiYZOkW0urORbryBqK6BsKkJtIKCojsQ1rvq9ojsvnpQc19KW(Oe6GQi1cjs9qIO0eLivXfvr0gjIcFufj1jLiLvkjZeIeUjvbXojsgkru0sPki9uenvIWvHirFvfjXyLivP9sXFryWqDyulgspgPjRKld2mr9zk1OHWPv8AvWSjCBvA3c)wQHlPoUkcwovEUQMoPRtvTDvuFxIY4HiPZtjA9er18vH2VOnEAKWqUyfmsjPYLu5LxQkxsBpl)e9SCpnKQL1GHSMPhyBWqg8fmKNuaxiuwyiRzlfnVmsyi)23rbdjcvRFpSvR2JIWhDt7R1FU(cwNoOowwT(ZLA1qI6pcT0cdQHCXkyKssLlPYlVuvUK2EwUhG0sssgYVgOgPKesljdjIzTGWGAixWtnK1ToDuu360brlt4hOUzjGfHSVZYSswW)HcBhWk4iKf8FGOLjGyjG)jKzfrF)SsU7vXfOiwDzG4jqhBIlqrKvSV9fcL1PJcuwvbq8u25GvwLvLKyjqmFIxGm7l0eZuD6iX1UPDJAzIfZRjE(eZ(AFzDOSqyzIPoGvyLyu(HvI7iXw2(UetrWoMQGBNvLK4stt88jMtmRkCR1eRDIRD95zbj2Y2pXLnkIeZjMP60rIfZRjwrWAINpXOTIiX)CRfqI5yL4Aht1HYOca5SQKexgIraj2bVVqNWoXtKyoXxGJjSL9fjMJvIT7EL4FU(cwNo2jU00eFzltC0AIDW7l0eprIveqIz0Vf(kiSmXigBeWRjUU)FqfqIx1)oRkjXsgaisSSdGeRDIH1OiNyEX1AI5yL45w76ZqIhnXANylBFxI7YIehaS(DwvsIjNRVG1PdjRJL1epFIzrzSLFIfDFyc7el3Ue7xVyf(eZXkXZT21NHle6NyTtSIas8cKzFHMyMQthjwmV(7SkRkjXNePcuFfwjgfKBhKyAFrznXOG9e)oXNMsHA9tC0bsIGDxzFrIzQoD8jUdHL7SIP60XVRDaTVOSwil4)qwXuD6431oG2xuw9wyvU7vwXuD6431oG2xuw9wyL9TVqOSoDKvLKyYGRFeTMyhpReJ6lldRe)kRFIrb52bjM2xuwtmkypXNyowjU2bizDR6e2jE(eV6a2zft1PJFx7aAFrz1BH1p46hrReVY6NvmvNo(DTdO9fLvVfw1wHlXLFfCwMvmvNo(DTdO9fLvVfw9FGyu4ICWxOGL8hb74NqUdLOLjQ7YaxwvsIrkFiXKA7UhaOgCjU2b0(IYAI9db8FI)(cjMxRpXLncrI)AUSiXF3XoRyQoD87Ahq7lkRElS(A7UhaOgCipYfklGq3V2U7baQb3gcgvaRtXJC8SiGZqOBET(nT9d1J9GJhD8SiGZqOBET(9ewejkVuYkMQth)U2b0(IYQ3cR1ToDKvmvNo(DTdO9fLvVfwbbCHqzbbQGFf5rUqzbe6geWfcLfeOc(1nemQawzft1PJFx7aAFrz1BHvbFMjq9DVI8ixybLfqOBqaxiuwqGk4x3qWOcyLvzvjj(KivG6RWkXWzWzzI15cjwrajMPA7s88jMpZJGrfWoRkjXsw(1elTO7LW)1eF5WNfclt8iNyfbK4tl5GBuiXs44rt8Pdk8QJfj2df(o4GcjE(ex7GhcDNvmvNo(cur3lH)RipYfSKdUrHnhu4vhliCW3bhuydbJkGvwvsIlTajP9fL1ex360rINpX1oqgCqOdlewMyXehGvI1oXkciXNAF2TgosClN4tl5GRveiNy)qa)NyAFrznXLncrIHyL4hr7uHL7SIP60X7TWADRthipYfasTgOkSiO9fLvcbe2kcKuNl4XiD5hps7wS6YITTp7wdheTmbl5GRveBhC5jEp2dkpRkjXLwOGZ5xRjULtmLF93zft1PJ3BH1YMyr8ia2LvmvNoEVfw9FGyu4(zft1PJ3BHv5XbeGaUqOSiRyQoD8ElS(A7UeGaUqOSiRyQoD8ElSIk6Eri77Se5rUWcklGq38tHyXbf2qWOcyD8iQVS8MFkeloOW2V(4rA3IvxwS5NcXIdkSDWLN4TisuEwXuD649wyffCp4omHnYJCHfuwaHU5NcXIdkSHGrfW64ruFz5n)uiwCqHTFDwXuD649wyvECaQO7fYJCHfuwaHU5NcXIdkSHGrfW64ruFz5n)uiwCqHTF9XJ0UfRUSyZpfIfhuy7GlpXBrKO8SIP60X7TWkhu4vhliOSqG8ixybLfqOB(PqS4GcBiyubSoEe1xwEZpfIfhuy7xF8iTBXQll28tHyXbf2o4Yt8wejkpRyQoD8ElSIY2eTmH6g6Hh5rUWcklGq38tHyXbf2qWOcyD8Ofq9LL38tHyXbf2(1zft1PJ3BHvNFqWuD6GqmVICWxOGBa5rUGP6CgiGaUd8wusNIh91GqqOSZg0FtrWtqigBeAmHTfL0XJFnieek7Sb93c(mtGc81IsQuYkMQthV3cRo)GGP60bHyEf5GVqXpHTaiu2zdAwLvLKypeFHojwzNnOjMP60rIRDt7g1YelMxZkMQth)MBO412Dpaqn4qEKluwaHUFTD3daudUnemQawzft1PJFZn4TWk)uiwCqHSIP60XV5g8wyvmNG)SiUS9Lj0wHBwXuD643CdElScStrCc(8biRyQoD8BUbVfwf8zMaf4lYJCHYci0n)uiwCqHnemQawzft1PJFZn4TWkfbpbHySrOXe2zft1PJFZn4TWQGpZeO(Uxr(2NNWUWtKh5cLfqOB(PqS4GcBiyubSYkMQth)MBWBHvzbFbIhrtpG8TppHDHNiRSZguIrUWbYo4rWOciRyQoD8BUbVfwLD9RepIMEa5BFEc7cpZQSQKetoHTasSeSZg0eFAQoDKyjt30UrTmXifZRzvjj(KX77GelzqM45tmt15mKy)qa)NylB)eJGpdj2ZtmXTlX32bj(vME4tClN4tLjwj(u7)AILD9nXKA7Uj(Kc4cHYIDI9OtUSHet5h8Wj2VM23jSt8PFAIr91eZuDodjM8KL(jE1XPQM4sjRyQoD87FcBbqOSZg0czbFbIhrtpGSYoBqjg5cpYc6qpmH9XJRw3Yc(cepIMEy7GlpX7Xf20vPCkwa1xwE)(oBGOLjQ7Ya32VoRyQoD87FcBbqOSZguVfw5NcXIdkKvmvNo(9pHTaiu2zdQ3cRGaUqOSGavWVMvmvNo(9pHTaiu2zdQ3cRV2U7baQbxwXuD643)e2cGqzNnOElSkMtWFwex2(YeARWnRyQoD87FcBbqOSZguVfw1wHlXLFfCwMvmvNo(9pHTaiu2zdQ3cRIXgHgtyti4)7SIP60XV)jSfaHYoBq9wyvWNzcuF3Rzft1PJF)tylacLD2G6TWQSRFL4r00dipYfO(YY7HcY(ol3(1zft1PJF)tylacLD2G6TW6qbzFNLzft1PJF)tylacLD2G6TWkWofbXJOPhqEKlq9LL3Y(I7eSoDSFLPhSybsNvmvNo(9pHTaiu2zdQ3cRIXgHgtytG2cnRyQoD87FcBbqOSZguVfwLf8fiEen9aY3(8e2fEISYoBqjg5chi7GhbJkGSIP60XV)jSfaHYoBq9wyvwWxG4r00diF7Ztyx4jYJCXTpdxi09AELdkyrKoRyQoD87FcBbqOSZguVfwLD9RepIMEa5BFEc7cpnK1UwEeGHSKeFsbCHqzrIjrWxoYQssmcvRFpSvR2JIWhDt7R1FU(cwNoOowwT(ZLAnRkjXN232)1e7z5iNyjvUNL6eJKjwsE6HlV8SkRkjXsweCydVhoRkjXizIrkFiXLEjabCHqzX2VoXowraUeRi4iXuea9We2jM2Ty1LfFI1oXpajEKtmiGlekl(eZoiXmvNZWoRkjXizIl9mpJkGvIpj7uej(Kc4cHYIedH6g43zvjjgjtShkC7ZqIp9tHyXbfsSoxWQ0ifjMIaOh2zvjjgjt8PxReFslHe3YjwrajMuB3nXwtShcOq72zvjjgjtCPfky7yfsSSFeGyc7epH2jwraj(0sMifj2JUGZg(elMx)eprIP(oheAIjNRKTu2zvwvsIpjsfO(kSsmki3oiX0(IYAIrb7j(DIpnLc16N4OdKeb7UY(IeZuD64tChcl3zvjjMP60XVRDaTVOSwil4)qwvsIzQoD87Ahq7lkRElSk39kRkjXmvNo(DTdO9fLvVfwzF7lekRthzvjjMm46hrRj2XZkXO(YYWkXVY6NyuqUDqIP9fL1eJc2t8jMJvIRDasw3QoHDINpXRoGDwvsIzQoD87Ahq7lkRElS(bx)iAL4vw)SIP60XVRDaTVOS6TWQ2kCjU8RGZYSQKeZuD6431oG2xuw9wyfyNIGaeWfcLfipYfwqzbe6U2nxwqac4cHYI51nemQawzvwvsIrkFiXKA7UhaOgCjU2b0(IYAI9db8FI)(cjMxRpXLncrI)AUSiXF3XoRQBD6OOU1PdIwMWpqDZsalczFNLzLSG)df2oGvWril4)arltaXsa)tiZkI((zLC3RIlqrS6YaXtGo2exGIiRyF7lekRthfOSQcG4PSZbRSkRkjXsGy(eVaz2xOjMP60rIRDt7g1YelMxt88jM91(Y6qzHWYetDaRWkXO8dRe3rITS9DjMIGDmvb3oRkjXLMM45tmNywv4wRjw7ex76ZZcsSLTFIlBuejMtmt1PJelMxtSIG1epFIrBfrI)5wlGeZXkX1oMQdLrfaYzvjjUmeJasSdEFHoHDINiXCIVahtyl7lsmhReB39kX)C9fSoDStCPPj(YwM4O1e7G3xOjEIeRiGeZOFl8vqyzIrm2iGxtCD))GkGeVQ)DwvsILmaqKyzhajw7edRrroX8IR1eZXkXZT21NHepAI1oXw2(Ue3Lfjoay97SQKetoxFbRthswhlRjE(eZIYyl)el6(We2jwUDj2VEXk8jMJvINBTRpdxi0pXANyfbK4fiZ(cnXmvNosSyE93zvwvsIpjsfO(kSsmki3oiX0(IYAIrb7j(DIpnLc16N4OdKeb7UY(IeZuD64tChcl3zft1PJFx7aAFrzTqwW)HSIP60XVRDaTVOS6TWQC3RSIP60XVRDaTVOS6TWk7BFHqzD6iRkjXKbx)iAnXoEwjg1xwgwj(vw)eJcYTdsmTVOSMyuWEIpXCSsCTdqY6w1jSt88jE1bSZkMQth)U2b0(IYQ3cRFW1pIwjEL1pRyQoD87Ahq7lkRElSQTcxIl)k4SmRyQoD87Ahq7lkRElS6)aXOWf5GVqbl5pc2XpHChkrltu3LbUSQKeJu(qIj12Dpaqn4sCTdO9fL1e7hc4)e)9fsmVwFIlBeIe)1CzrI)UJDwXuD6431oG2xuw9wy912Dpaqn4qEKluwaHUFTD3daudUnemQawNIh54zraNHq38A9BA7hQh7bhp64zraNHq38A97jSisuEPKvmvNo(DTdO9fLvVfwRBD6iRyQoD87Ahq7lkRElScc4cHYccub)kYJCHYci0niGlekliqf8RBiyubSYkMQth)U2b0(IYQ3cRc(mtG67Ef5rUWcklGq3GaUqOSGavWVUHGrfWkRYQss8jrQa1xHvIHZGZYeRZfsSIasmt12L45tmFMhbJkGDwvsILS8RjwAr3lH)Rj(YHplewM4roXkciXNwYb3OqILWXJM4thu4vhlsShk8DWbfs88jU2bpe6oRyQoD8fOIUxc)xrEKlyjhCJcBoOWRowq4GVdoOWgcgvaRSQKexAbss7lkRjUU1PJepFIRDGm4GqhwiSmXIjoaReRDIveqIp1(SBnCK4woXNwYbxRiqoX(Ha(pX0(IYAIlBeIedXkXpI2Pcl3zft1PJ3BH16wNoqEKlaKAnqvyrq7lkReciSveiPoxWJr6YpEK2Ty1LfBBF2TgoiAzcwYbxRi2o4Yt8EShuEwvsIlTqbNZVwtClNyk)6VZkMQthV3cRLnXI4raSlRyQoD8ElS6)aXOW9ZkMQthV3cRYJdiabCHqzrwXuD649wy912DjabCHqzrwXuD649wyfv09Iq23zjYJCHfuwaHU5NcXIdkSHGrfW64ruFz5n)uiwCqHTF9XJ0UfRUSyZpfIfhuy7GlpXBrKO8SIP60X7TWkk4EWDycBKh5clOSacDZpfIfhuydbJkG1XJO(YYB(PqS4GcB)6SIP60X7TWQ84aur3lKh5clOSacDZpfIfhuydbJkG1XJO(YYB(PqS4GcB)6JhPDlwDzXMFkeloOW2bxEI3Iir5zft1PJ3BHvoOWRowqqzHa5rUWcklGq38tHyXbf2qWOcyD8iQVS8MFkeloOW2V(4rA3IvxwS5NcXIdkSDWLN4TisuEwXuD649wyfLTjAzc1n0dpYJCHfuwaHU5NcXIdkSHGrfW64rlG6llV5NcXIdkS9RZkMQthV3cRo)GGP60bHyEf5GVqb3aYJCbt15mqabCh4TOKofp6RbHGqzNnO)MIGNGqm2i0ycBlkPJh)Aqiiu2zd6Vf8zMaf4RfLuPKvmvNoEVfwD(bbt1PdcX8kYbFHIFcBbqOSZg0SkRkjXEi(cDsSYoBqtmt1PJex7M2nQLjwmVMvmvNo(n3qXRT7EaGAWH8ixOSacD)A7UhaOgCBiyubSYkMQth)MBWBHv(PqS4Gczft1PJFZn4TWQyob)zrCz7ltOTc3SIP60XV5g8wyfyNI4e85dqwXuD643CdElSk4ZmbkWxKh5cLfqOB(PqS4GcBiyubSYkMQth)MBWBHvkcEccXyJqJjSZkMQth)MBWBHvbFMjq9DVI8TppHDHNipYfklGq38tHyXbf2qWOcyLvmvNo(n3G3cRYc(cepIMEa5BFEc7cprwzNnOeJCHdKDWJGrfqwXuD643CdElSk76xjEen9aY3(8e2fEMvzvjjMCcBbKyjyNnOj(0uD6iXsMUPDJAzIrkMxZQss8jJ33bjwYGmXZNyMQZziX(Ha(pXw2(jgbFgsSNNyIBxIVTds8Rm9WN4woXNktSs8P2)1el76BIj12Dt8jfWfcLf7e7rNCzdjMYp4HtSFnTVtyN4t)0eJ6RjMP6Cgsm5jl9t8QJtvnXLswXuD643)e2cGqzNnOfYc(cepIMEazLD2GsmYfEKf0HEyc7JhxTULf8fiEen9W2bxEI3JlSPRs5uSaQVS8(9D2arltu3LbUTFDwXuD643)e2cGqzNnOElSYpfIfhuiRyQoD87FcBbqOSZguVfwbbCHqzbbQGFnRyQoD87FcBbqOSZguVfwFTD3daudUSIP60XV)jSfaHYoBq9wyvmNG)SiUS9Lj0wHBwXuD643)e2cGqzNnOElSQTcxIl)k4SmRyQoD87FcBbqOSZguVfwfJncnMWMqW)3zft1PJF)tylacLD2G6TWQGpZeO(UxZkMQth)(NWwaek7Sb1BHvzx)kXJOPhqEKlq9LL3dfK9DwU9RZkMQth)(NWwaek7Sb1BH1HcY(olZkMQth)(NWwaek7Sb1BHvGDkcIhrtpG8ixG6llVL9f3jyD6y)ktpyXcKoRyQoD87FcBbqOSZguVfwfJncnMWMaTfAwXuD643)e2cGqzNnOElSkl4lq8iA6bKV95jSl8ezLD2GsmYfoq2bpcgvazft1PJF)tylacLD2G6TWQSGVaXJOPhq(2NNWUWtKh5IBFgUqO718khuWIiDwXuD643)e2cGqzNnOElSk76xjEen9aY3(8e2fEAipdUF6WiLKkxsLxEPtsiTHSm2fty)gYs7w3ofwj(etmt1PJelMx)DwzizFfr7mKKZ1xW60HK1XYQHumV(gjmK)e2cGqzNnOgjms5PrcdjemQawgPnKu3OGBydPhLylKyDOhMWoXhpM4vRBzbFbIhrtpSDWLN4tShxKyB6kXLsIpLeBHeJ6llVFFNnq0Ye1DzGB7xBizQoDyiLf8fiEen9GrnsjjJegsMQthgs(PqS4GcgsiyubSmsBuJuEGrcdjt1PddjiGlekliqf8RgsiyubSmsBuJuNOrcdjt1Pdd5RT7EaGAWziHGrfWYiTrnsHegjmKmvNomKI5e8NfXLTVmH2kCnKqWOcyzK2OgPqAJegsMQthgsTv4sC5xbNLgsiyubSmsBuJuLoJegsMQthgsXyJqJjSje8)THecgvalJ0g1ivPYiHHKP60HHuWNzcuF3RgsiyubSmsBuJuLAJegsiyubSmsBiPUrb3WgsuFz59qbzFNLB)Adjt1PddPSRFL4r00dg1iLNLBKWqYuD6Wqouq23zPHecgvalJ0g1iLNEAKWqcbJkGLrAdj1nk4g2qI6llVL9f3jyD6y)ktpKylwKyK2qYuD6WqcStrq8iA6bJAKYtjzKWqYuD6WqkgBeAmHnbAludjemQawgPnQrkp9aJegsiyubSmsBiHGrfaXTppHTrAdjt1PddPSGVaXJOPhmKu3OGBydPdKDWJGrfGH82NNW2iLNg1iLNNOrcdjemQawgPnKqWOcG42NNW2iTHK6gfCdBiV9z4cHUxZRCqHeBXeJ0gsMQthgszbFbIhrtpyiV95jSns5Prns5jsyKWqE7ZtyBKYtdjemQaiU95jSnsBizQoDyiLD9RepIMEWqcbJkGLrAJAudj3GrcJuEAKWqcbJkGLrAdj1nk4g2qQSacD)A7UhaOgCBiyubSmKmvNomKV2U7baQbNrnsjjJegsMQthgs(PqS4GcgsiyubSmsBuJuEGrcdjt1PddPyob)zrCz7ltOTcxdjemQawgPnQrQt0iHHKP60HHeyNI4e85dGHecgvalJ0g1ifsyKWqcbJkGLrAdj1nk4g2qQSacDZpfIfhuydbJkGLHKP60HHuWNzcuGVg1ifsBKWqYuD6WqsrWtqigBeAmHTHecgvalJ0g1ivPZiHHecgvalJ0gsiyubqC7ZtyBK2qsDJcUHnKklGq38tHyXbf2qWOcyzizQoDyif8zMa139QH82NNW2iLNg1ivPYiHHecgvalJ0gsiyubqC7ZtyBK2qYuD6Wqkl4lq8iA6bdj1nk4g2q6azh8iyubyiV95jSns5PrnsvQnsyiV95jSns5PHecgvae3(8e2gPnKmvNomKYU(vIhrtpyiHGrfWYiTrnQHCbYSVqnsyKYtJegsiyubSmOgsQBuWnSHKLCWnkS5GcV6ybHd(o4GcBiyubSmKmvNomKOIUxc)xnQrkjzKWqcbJkGLrAdj1nk4g2qci1AGQWIG2xuwjeqyRismsMyDUqI94eJ0LN4JhtmTBXQll22(SBnCq0YeSKdUwrSDWLN4tShNypOCdjt1PddzDRthg1iLhyKWqYuD6Wqw2elIhbWodjemQawgPnQrQt0iHHKP60HH0)bIrH7BiHGrfWYiTrnsHegjmKmvNomKYJdiabCHqzHHecgvalJ0g1ifsBKWqYuD6Wq(A7UeGaUqOSWqcbJkGLrAJAKQ0zKWqcbJkGLrAdj1nk4g2qAHeRSacDZpfIfhuydbJkGvIpEmXO(YYB(PqS4GcB)6eF8yIPDlwDzXMFkeloOW2bxEIpXwmXir5gsMQthgsur3lczFNLg1ivPYiHHecgvalJ0gsQBuWnSH0cjwzbe6MFkeloOWgcgvaReF8yIr9LL38tHyXbf2(1gsMQthgsuW9G7We2g1ivP2iHHecgvalJ0gsQBuWnSH0cjwzbe6MFkeloOWgcgvaReF8yIr9LL38tHyXbf2(1j(4Xet7wS6YIn)uiwCqHTdU8eFITyIrIYnKmvNomKYJdqfDVmQrkpl3iHHecgvalJ0gsQBuWnSH0cjwzbe6MFkeloOWgcgvaReF8yIr9LL38tHyXbf2(1j(4Xet7wS6YIn)uiwCqHTdU8eFITyIrIYnKmvNomKCqHxDSGGYcHrns5PNgjmKqWOcyzK2qsDJcUHnKwiXklGq38tHyXbf2qWOcyL4JhtSfsmQVS8MFkeloOW2V2qYuD6WqIY2eTmH6g6H3OgP8usgjmKqWOcyzK2qsDJcUHnKmvNZabeWDGpXwmXskXNsI9Oe)1GqqOSZg0FtrWtqigBeAmHDITyILuIpEmXFnieek7Sb93c(mtGc8nXwmXskXLIHKP60HH05hemvNoieZRgsX8krWxWqYnyuJuE6bgjmKqWOcyzK2qYuD6Wq68dcMQtheI5vdPyELi4lyi)jSfaHYoBqnQrnK1oG2xuwnsyKYtJegsMQthgsTv4sC5xbNLgsiyubSmsBuJusYiHHecgvalJ0g1iLhyKWqcbJkGLrAJAK6ensyiHGrfWYiTrnsHegjmKqWOcyzK2OgPqAJegsMQthgsTv4sC5xbNLgsiyubSmsBuJuLoJegsiyubSmsBid(cgswYFeSJFc5ouIwMOUldCgsMQthgswYFeSJFc5ouIwMOUldCg1ivPYiHHecgvalJ0gsQBuWnSHuzbe6(12Dpaqn42qWOcyL4tjXEuID8SiGZqOBET(nT9dnXECI9GeF8yID8SiGZqOBET(9ej2IjgjkpXLIHKP60HH812Dpaqn4mQrQsTrcdjt1PddzDRthgsiyubSmsBuJuEwUrcdjemQawgPnKu3OGBydPYci0niGlekliqf8RBiyubSmKmvNomKGaUqOSGavWVAuJuE6PrcdjemQawgPnKu3OGBydPfsSYci0niGlekliqf8RBiyubSmKmvNomKc(mtG67E1Og1Og1Ogda]] )

end
