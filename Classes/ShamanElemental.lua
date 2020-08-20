-- ShamanElemental.lua
-- 07.2020

-- TODOs:
-- Legendaries
-- Covenant abilities
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
        elemental_blast = 22358, -- 117014

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
            id = 260111,
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
                    addStack( "fulmination", nil, 1 )
                end

                if buff.stormkeeper.up then
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
                return max( 0, 1 - 0.2 * buff.fulmination.stack ) * 3 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            -- TODO: add echoes of the great sundering legendary buff
            startsCombat = true,
            texture = 451165,

            handler = function ()
                -- TODO: recycle buff
                --removeBuff( "echoes_of_the_great_sundering" )
                removeBuff( "fulmination" )
                removeBuff( "master_of_the_elements" )
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
                    addStack( "fulmination", nil, 1)
                end

                if buff.stormkeeper.up then
                    if active_enemies > 1 then
                        addStack( "fulmination", nil, min( 5, active_enemies ))
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
                addStack( "fulmination", nil, 1 )

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
                    addStack( "fulmination", nil, 1 )
                    removeStack( "stormkeeper" )
                end

                if buff.surge_of_power.up then
                    addStack( "fulmination", nil, 1 )
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

        static_discharge = {
            id = 342243,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
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

    spec:RegisterPack( "Elemental", 20200813.1, [[dGeOBaqieKhHGAtsO4tsisJIqvofHIELuYSiKUfHi2Ls(ffzyckhdbwMGQNPkLPPkjxJqLTjH03ieQXrOQohHqwNek9ocbQ5riQ7Pk2NQuDqjewOe8qcbDrcf2OeQIpkHiojHiTse1mLqv1nLqvzNuudLqawkHa5PuAQcYvjeqFvcvP9k6VQQblPdJAXk1JHmzP6YGnlWNPWOrOtR41srZgPBtWUP63QmCe54sOYYf65qnDsxxI2UuQVRkX4LquNNqP1RkPMVuy)eDsqgkTDwH0C4HfEyHj(e82k83Evrf3BPvfljiTKyut2asRZcqAfdkiaUY00sIfl94EgkT4RmIG0suvs4I1KjJrjwUxOtWeEekPSoNJICGAcpcitPDxouvK65oTDwH0C4HfEyHj(e82k83Evrfx4PftcqP5WlA4PL407GN702bmkTewwfdkiaUYuz1sKfyxsMWYkrvjHlwtMmgLy5EHobt4rOKY6CokYbQj8iGmjjtyzTiknkXQSsWBIkRHhw4HjjljtyzvesKDdaxSPLu8cgkKwclRIbfeaxzQSAjYcSljtyzLOQKWfRjtgJsSCVqNGj8iuszDohf5a1eEeqMKKjSSweLgLyvwj4nrL1Wdl8WKKLKjSSkcjYUbGlwjzjzgPZ54fPiGoHnRpbug3usMr6CoErkcOtyZARhtb31LKzKoNJxKIa6e2S26XexAiaUY6CUKmHLvRZKWepvwJ80L1Dzqa0LvSYkww3qWfbzfDcBwL1nymowwzVlRKIGiH0P64gY6GL1(5WssMr6CoErkcOtyZARhtyNjHjE6hRSILKzKoNJxKIa6e2S26Xujg(JccI6Sa8WVgtKJm(hCU(VGpP7fikjtyzveigKvRErHMaqcIYkPiGoHnRYAPtbmwwXNaiRCVJL1xgkvwXK4xCzfFNVKKzKoNJxKIa6e2S26XewVOqtaibrrNGhLPGRlSErHMaqcIlW5nf6fJ4f5P)H2GRlU3Xl0v6Qi)wJgrE6FOn46I7D8A83fxyIPKmJ05C8IueqNWM1wpMiD6CUKmJ05C8IueqNWM1wpMakiaUY0)MYyv0j4rzk46cOGa4kt)BkJ1f48McDjzgPZ54fPiGoHnRTEmr528FxgXQOtWdHuMcUUakiaUY0)MYyDboVPqxswsMWYQyuKbuPcDzfAdrXkR6iaYQseKvgPxuwhSSYT5HYBkSKKjSSkczSkRfO31PLyvwfyVKPuXkRtGSQebzTiEnehfK1qrEuzTiCeG1itLvrqa(C2rGSoyzLueWGRljzgPZ54Nn9UoTeRIobp8RH4OWIDeG1it)raFo7iyboVPqxsMWYQi1fjOtyZQSs605CzDWYkPiearW1HPuXkR0XBcDzvpzvjcYArsjh7d7Y6fiRfXRH4PefvwlDkGXYk6e2SkRVmuQScExwXeVOsf7ssMr6CoU1JjsNoNl6e8afzsasH(hDcBw)uWnuIIeDearUOH1Ob6oA)EXxgLCSpS)VGp)AiEkXvee4XXI8BHjjtyzvK6keJLKuz9cKveJv8ssMr6CoU1JPxgV)XebokjZiDoh36Xujg(JccyjzgPZ54wpMcMi8bkiaUYujzgPZ54wpMW6ff(afeaxzQKmJ05CCRhtB6D9FqzuSIobpeszk46IXiW7SJGf48Mc9gn2LbblgJaVZocwLKA0aDhTFV4lgJaVZocwrqGhh)U4ctsMr6CoU1JPneXqS54gIobpeszk46IXiW7SJGf48Mc9gn2LbblgJaVZocwLKKKzKoNJB9ykyIWMExx0j4HqktbxxmgbENDeSaN3uO3OXUmiyXye4D2rWQKuJgO7O97fFXye4D2rWkcc8443fxysYmsNZXTEmXocWAKPFetPIobpeszk46IXiW7SJGf48Mc9gn2LbblgJaVZocwLKA0aDhTFV4lgJaVZocwrqGhh)U4ctsMr6CoU1JPnB8VGVghutSOtWdHuMcUUymc8o7iyboVPqVrdcTldcwmgbENDeSkjjjZiDoh36XuS0)msNZ)0bRI6Sa8Whi6e8WiDAdFWbHbWVhEXiEysaL(voAakEHiYJ)PJbr1h349WB0atcO0VYrdqXlk3M)BGfEpCXusMr6CoU1JPyP)zKoN)Pdwf1zb4bpUbf(khnavswsMWYAXxjvhzv5ObOYkJ05CzLuCU4OIvwPdwLKzKoNJx8bpy9IcnbGeefDcEuMcUUW6ffAcajiUaN3uOljZiDohV4dA9yIXiW7SJajzgPZ54fFqRht0P4kN(xGne4VEkiijZiDohV4dA9yc4OsS4k5MGKmJ05C8IpO1Jjk3M)BGfeDcEuMcUUymc8o7iyboVPqxsMr6CoEXh06XeIip(NogevFCdjzgPZ54fFqRhtyL1b97dgrKJgGKmJ05C8IpO1Jjk3M)7Yiwfv4ApUXdbIobpktbxxmgbENDeSaN3uOljZiDohV4dA9ykGYcWht8qnfv4ApUXdbIQC0a0)e8eHGiGjYBkijZiDohV4dA9ykiEy9JjEOMIkCTh34HajzjzclR2XnOGSgIJgGkRfbsNZLvraX5IJkwzT4FWQKmHLvXWXLrqwlESY6GLvgPtBqwlDkGXYQyVszLi3gKvcELSErzv4IGSIvg1elRxGSw8oExwlskXQSgepbz1QxuqwfdkiaUY0LSkEIr3aKveJHIvwljHoHXnK1IaJK1DPkRmsN2GSAfdrWYA)8IuvwftjzgPZ54fECdk8voAa6taLfGpM4HAkQYrdq)tWJ4riDqnh3OrJ(PRaklaFmXd1CfbbECSi)yG6IzXqODzqWcxgnG)f8jDVaXvjjjzgPZ54fECdk8voAaARhtmgbENDeijZiDohVWJBqHVYrdqB9ycOGa4kt)BkJvjzgPZ54fECdk8voAaARhty9IcnbGeeLKzKoNJx4XnOWx5ObOTEmrNIRC6Fb2qG)6PGGKmJ05C8cpUbf(khnaT1Jj6yqu9Xn(ugJpjzgPZ54fECdk8voAaARhtuUn)3LrSkjZiDohVWJBqHVYrdqB9ykiEy9JjEOMIobp7YGG1GGGYOyxLKKKzKoNJx4XnOWx5ObOTEmniiOmkwjzgPZ54fECdk8voAaARhtahvIFmXd1u0j4zxgeSckPcJZ6C(cRmQ57pfvsMr6CoEHh3GcFLJgG26XewzDq)(Gre5ObijZiDohVWJBqHVYrdqB9yIogevFCJ)(OQKmJ05C8cpUbf(khnaT1JPaklaFmXd1uuHR94gpeiQYrdq)tWtecIaMiVPGKmJ05C8cpUbf(khnaT1JPaklaFmXd1uuHR94gpei6e8iCTbbW1vFWk7i49IkjZiDohVWJBqHVYrdqB9ykiEy9JjEOMIkCTh34HG02gI4580C4HfEyHj(e8wAFHJ(4g40ksfiDrf6Y6RKvgPZ5YkDWkEjjNw6GvCgkT4XnOWx5ObOzO0mbzO0coVPqplKwuCuioCAfpzLqYQoOMJBiRnAiR9txbuwa(yIhQ5kcc84yzvKFKvduxwftzTyKvcjR7YGGfUmAa)l4t6EbIRssPLr6CEAdOSa8XepuZutZHNHslJ0580Yye4D2rqAbN3uONfsnn)wgkTmsNZtlqbbWvM(3ugRPfCEtHEwi108RYqPLr6CEAX6ffAcajiMwW5nf6zHutZIldLwgPZ5PLofx50)cSHa)1tbH0coVPqplKAAUOzO0YiDopT0XGO6JB8PmgFPfCEtHEwi10SiodLwgPZ5PLYT5)UmI10coVPqplKAAw8ZqPfCEtHEwiTO4OqC40UldcwdcckJIDvskTmsNZtBq8W6ht8qntnnlIYqPLr6CEAheeugfBAbN3uONfsnntqyzO0coVPqplKwuCuioCA3LbbRGsQW4SoNVWkJAkRV)iRfnTmsNZtlWrL4ht8qntnntabzO0YiDopTyL1b97dgrKJgqAbN3uONfsnntq4zO0YiDopT0XGO6JB83hvtl48Mc9SqQPzcEldLwW5nf6zH0coVPWx4ApUrwiTmsNZtBaLfGpM4HAMwuCuioCAJqqeWe5nfsRW1ECJ0mbPMMj4vzO0coVPqplKwW5nf(cx7XnYcPffhfIdNwHRniaUU6dwzhbY67YArtlJ0580gqzb4JjEOMPv4ApUrAMGutZeiUmuAfU2JBKMjiTGZBk8fU2JBKfslJ0580gepS(XepuZ0coVPqplKAQPLpidLMjidLwW5nf6zH0IIJcXHtRYuW1fwVOqtaibXf48Mc90YiDopTy9IcnbGeetnnhEgkTmsNZtlJrG3zhbPfCEtHEwi108BzO0YiDopT0P4kN(xGne4VEkiKwW5nf6zHutZVkdLwgPZ5Pf4OsS4k5MqAbN3uONfsnnlUmuAbN3uONfslkokehoTktbxxmgbENDeSaN3uONwgPZ5PLYT5)gyHutZfndLwgPZ5PfrKh)thdIQpUrAbN3uONfsnnlIZqPLr6CEAXkRd63hmIihnG0coVPqplKAAw8ZqPfCEtHEwiTGZBk8fU2JBKfslkokehoTktbxxmgbENDeSaN3uONwgPZ5PLYT5)UmI10kCTh3intqQPzrugkTGZBk0ZcPfCEtHVW1ECJSqAzKoNN2aklaFmXd1mTO4OqC40gHGiGjYBkKwHR94gPzcsnntqyzO0kCTh3intqAbN3u4lCTh3ilKwgPZ5PniEy9JjEOMPfCEtHEwi1utBhc4sQMHsZeKHsl48Mc9CNwuCuioCA5xdXrHf7iaRrM(Ja(C2rWcCEtHEAzKoNN2n9UoTeRPMMdpdLwW5nf6zH0IIJcXHtluKjbif6F0jSz9tb3qjkRIezvhbqwfzzTOHjRnAiRO7O97fFzuYX(W()c(8RH4PexrqGhhlRISS(wyPLr6CEAjD6CEQP53YqPLr6CEAFz8(hte4yAbN3uONfsnn)QmuAzKoNN2sm8hfeWPfCEtHEwi10S4YqPLr6CEAdMi8bkiaUY00coVPqplKAAUOzO0YiDopTy9IcFGccGRmnTGZBk0ZcPMMfXzO0coVPqplKwuCuioCAjKSQmfCDXye4D2rWcCEtHUS2OHSUldcwmgbENDeSkjjRnAiRO7O97fFXye4D2rWkcc84yz9DzvCHLwgPZ5PDtVR)dkJIn10S4NHsl48Mc9SqArXrH4WPLqYQYuW1fJrG3zhblW5nf6YAJgY6UmiyXye4D2rWQKuAzKoNN2neXqS54gPMMfrzO0coVPqplKwuCuioCAjKSQmfCDXye4D2rWcCEtHUS2OHSUldcwmgbENDeSkjjRnAiRO7O97fFXye4D2rWkcc84yz9DzvCHLwgPZ5PnyIWMExp10mbHLHsl48Mc9SqArXrH4WPLqYQYuW1fJrG3zhblW5nf6YAJgY6UmiyXye4D2rWQKKS2OHSIUJ2Vx8fJrG3zhbRiiWJJL13LvXfwAzKoNNw2rawJm9Jykn10mbeKHsl48Mc9SqArXrH4WPLqYQYuW1fJrG3zhblW5nf6YAJgYkHK1DzqWIXiW7SJGvjP0YiDopTB24FbFnoOM4utZeeEgkTGZBk0ZcPffhfIdNwgPtB4doimawwFxwdxwlgzv8KvmjGs)khnafVqe5X)0XGO6JBiRVlRHlRnAiRysaL(voAakEr528FdSGS(USgUSkMPLr6CEAJL(Nr6C(NoynT0bRFNfG0YhKAAMG3YqPfCEtHEwiTmsNZtBS0)msNZ)0bRPLoy97SaKw84gu4RC0a0utnTKIa6e2SMHsZeKHsl48Mc9SqQP5WZqPfCEtHEwi108BzO0coVPqplKAA(vzO0coVPqplKAAwCzO0coVPqplKwNfG0YVgtKJm(hCU(VGpP7fiMwgPZ5PLFnMihz8p4C9FbFs3lqm10CrZqPfCEtHEwiTO4OqC40QmfCDH1lk0easqCboVPqxwlgzv8K1ip9p0gCDX9oEHUsxLvrwwFtwB0qwJ80)qBW1f37414Y67YQ4ctwfZ0YiDopTy9IcnbGeetnnlIZqPLr6CEAjD6CEAbN3uONfsnnl(zO0coVPqplKwuCuioCAvMcUUakiaUY0)MYyDboVPqpTmsNZtlqbbWvM(3ugRPMMfrzO0coVPqplKwuCuioCAjKSQmfCDbuqaCLP)nLX6cCEtHEAzKoNNwk3M)7Yiwtn1utlxQeVyATJqjL15CryKd0utnta]] )

end
