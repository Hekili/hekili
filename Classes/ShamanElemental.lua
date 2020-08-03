-- ShamanElemental.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 262, true )

    spec:RegisterResource( Enum.PowerType.Maelstrom, {
        resonance_totem = {
            aura = 'resonance_totem',

            last = function ()
                local app = state.buff.resonance_totem.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 1,
        },
    } )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        earthen_rage = 22356, -- 170374
        echo_of_the_elements = 22357, -- 108283
        elemental_blast = 22358, -- 117014

        aftershock = 23108, -- 273221
        call_the_thunder = 22139, -- 260897
        totem_mastery = 23190, -- 210643

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
        relentless = 3596, -- 196029
        adaptation = 3597, -- 214027
        gladiators_medallion = 3598, -- 208683

        spectral_recovery = 3062, -- 204261
        control_of_lava = 728, -- 204393
        earthfury = 729, -- 204398
        traveling_storms = 730, -- 204403
        lightning_lasso = 731, -- 204437
        elemental_attunement = 727, -- 204385
        skyfury_totem = 3488, -- 204330
        grounding_totem = 3620, -- 204336
        counterstrike_totem = 3490, -- 204331
        purifying_waters = 3491, -- 204247
        swelling_waves = 3621, -- 204264
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

        earthquake = {
            id = 61882,
            duration = 3600,
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
                eb.caster = count > 0 and 'player' or 'nobody'
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

        ember_totem = {
            id = 210658,
            duration = 0,
            max_stack = 1,
        },

        exposed_elements = {
            id = 269808,
            duration = 15,
            max_stack = 1,
        },

        far_sight = {
            id = 6196,
            duration = 60,
            max_stack = 1,
        },

        flame_shock = {
            id = 188389,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
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

        master_of_the_elements = {
            id = 260734,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        resonance_totem = {
            id = 202192,
            duration = 120,
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

        storm_totem = {
            id = 210652,
            duration = 120,
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

        tailwind_totem = {
            id = 210659,
            duration = 120,
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
            max_stack = 10, -- this is a guess.
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
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        if cast + duration > expires then
                            expires = cast + duration
                            remains = expires - now
                        end
                    end
                end

                local up = PlayerBuffUp( "resonance_totem" ) and remains > 0

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if expires > 0 and up then
                    tm.count = 4
                    tm.expires = expires
                    tm.applied = expires - 120
                    tm.caster = "player"

                    applyBuff( "resonance_totem", remains )
                    applyBuff( "tailwind_totem", remains )
                    applyBuff( "storm_totem", remains )
                    applyBuff( "ember_totem", remains )
                    return
                end

                tm.count = 0
                tm.expires = 0
                tm.applied = 0
                tm.caster = "nobody"

                removeBuff( 'resonance_totem' )
                removeBuff( 'storm_totem' )
                removeBuff( 'ember_totem' )
                removeBuff( 'tailwind_totem' )
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


    spec:RegisterStateTable( 'fire_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.fire_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'down' then
                return not elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'storm_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.storm_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'down' then
                return not elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'earth_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.earth_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'down' then
                return not elem.up

            elseif k == 'remains' then
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


    local hadTotem = false
    local hadTotemAura = false

    spec:RegisterHook( "reset_precast", function ()
        class.auras.totem_mastery.generate()

        if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
            applyBuff( "master_of_the_elements" )
        end
    end )


    spec:RegisterGear( "the_deceivers_blood_pact", 137035 ) -- 20% chance; not modeled.
    spec:RegisterGear( "alakirs_acrimony", 137102 ) -- passive dmg increase.
    spec:RegisterGear( "echoes_of_the_great_sundering", 137074 )
        spec:RegisterAura( "echoes_of_the_great_sundering", {
            id = 208723, 
            duration =  10
        } )

    spec:RegisterGear( "pristine_protoscale_girdle", 137083 ) -- not modeled.
    spec:RegisterGear( "eye_of_the_twisting_nether", 137050 )
        spec:RegisterAura( "fire_of_the_twisting_nether", {
            id = 207995,
            duration = 8 
        } )
        spec:RegisterAura( "chill_of_the_twisting_nether", {
            id = 207998,
            duration = 8 
        } )
        spec:RegisterAura( "shock_of_the_twisting_nether", {
            id = 207999,
            duration = 8 
        } )

        spec:RegisterStateTable( "twisting_nether", setmetatable( {}, {
            __index = function( t, k )
                if k == 'count' then
                    return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
                end

                return 0
            end
        } ) )

    spec:RegisterGear( "uncertain_reminder", 143732 )


    -- Abilities
    spec:RegisterAbilities( {
        ancestral_guidance = {
            id = 108281,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = 'ancestral_guidance',

            startsCombat = false,
            texture = 538564,

            handler = function ()
                applyBuff( 'ancestral_guidance' )
            end,
        },


        ancestral_spirit = {
            id = 2008,
            cast = 10.000215022888,
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

            toggle = 'cooldowns',
            talent = 'ascendance',

            startsCombat = false,
            texture = 135791,

            handler = function ()
                applyBuff( 'ascendance' )
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

            startsCombat = false,
            texture = 538565,

            handler = function ()
                applyBuff( 'astral_shift' )
            end,
        },


        --[[ bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 136012,

            handler = function ()
                applyBuff( 'bloodlust' )
                applyDebuff( 'player', 'sated' )
            end,
        }, ]]


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


        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.tectonic_thunder.up or buff.stormkeeper.up ) and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            nobuff = 'ascendance',
            bind = 'lava_beam',

            startsCombat = true,
            texture = 136015,

            handler = function ()
                removeBuff( "master_of_the_elements" )

                if buff.stormkeeper.up then
                    gain( 2 * min( 5, active_enemies ), "maelstrom" )
                    removeStack( "stormkeeper" )
                else
                    removeBuff( "tectonic_thunder" )
                end

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end

                natural_harmony( "nature" )

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
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

            talent = 'earth_shield',

            startsCombat = false,
            texture = 136089,

            handler = function ()
                applyBuff( 'earth_shield' )                
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
                if talent.exposed_elements.enabled then applyBuff( 'exposed_elements' ) end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                if talent.surge_of_power.enabled then applyBuff( "surge_of_power" ) end

                natural_harmony( "nature" )
            end,
        },


        earthbind_totem = {
            id = 2484,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

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

            spend = function () return buff.echoes_of_the_great_sundering.up and 0 or 60 end,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 451165,

            handler = function ()
                removeBuff( "echoes_of_the_great_sundering" )
                removeBuff( "master_of_the_elements" )
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                natural_harmony( "nature" )
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
                applyBuff( 'elemental_blast' )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( "fire_of_the_twisting_nether" )
                    applyBuff( "chill_of_the_twisting_nether" )
                    applyBuff( "shock_of_the_twisting_nether" )
                end

                natural_harmony( "fire", "frost", "nature" )
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

            toggle = 'cooldowns',
            notalent = 'storm_elemental',

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
                applyDebuff( 'target', 'flame_shock' )
                if buff.surge_of_power.up then
                    active_dot.surge_of_power = min( active_enemies, active_dot.flame_shock + 1 )
                    removeBuff( "surge_of_power" )
                end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
                natural_harmony( "fire" )
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
                removeBuff( 'master_of_the_elements' )
                applyDebuff( 'target', 'frost_shock' )

                if buff.icefury.up then
                    gain( 8, "maelstrom" )
                    removeStack( "icefury", 1 )
                end

                if buff.surge_of_power.up then
                    applyDebuff( "target", "surge_of_power_debuff" )
                    removeBuff( "surge_of_power" )
                end

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "chill_of_the_twisting_nether" ) end
                natural_harmony( "frost" )
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
                applyBuff( 'ghost_wolf' )
                if talent.spirit_wolf.enabled then applyBuff( 'spirit_wolf' ) end
            end,
        },


        healing_surge = {
            id = 8004,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.2,
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
                applyDebuff( 'target', 'hex' )
            end,
        },


        icefury = {
            id = 210714,
            cast = 1.9996204751587,
            cooldown = 30,
            gcd = "spell",

            spend = -25,
            spendType = 'maelstrom',

            startsCombat = true,
            texture = 135855,

            handler = function ()
                removeBuff( 'master_of_the_elements' )
                applyBuff( 'icefury', 15, 4 )
                natural_harmony( "frost" )
            end,
        },


        lava_beam = {
            id = 114074,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            buff = 'ascendance',
            bind = 'chain_lightning',

            startsCombat = true,
            texture = 236216,

            handler = function ()
                removeStack( 'stormkeeper' )
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
                natural_harmony( "fire" )
            end,
        },


        lava_burst = {
            id = 51505,
            cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
            charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
            cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            gcd = "spell",

            spend = -10,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 237582,

            handler = function ()
                removeBuff( "lava_surge" )
                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end
                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
                end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
                natural_harmony( "fire" )
            end,
        },


        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 136048,

            handler = function ()
                removeBuff( "master_of_the_elements" )

                if buff.stormkeeper.up then
                    gain( 3, "maelstrom" )
                    removeStack( 'stormkeeper' )
                end

                if buff.surge_of_power.up then
                    gain( 3, "maelstrom" )
                    removeBuff( "surge_of_power" )
                end

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                natural_harmony( "nature" )
            end,
        },


        lightning_lasso = {
            id = 305483,
            cast = 5,
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

            startsCombat = true,
            texture = 971079,

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


        storm_elemental = {
            id = 192249,
            cast = 0,
            charges = 1,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 150 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 150 end,
            gcd = "spell",

            toggle = 'cooldowns',
            talent = 'storm_elemental',

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

            talent = 'stormkeeper',

            startsCombat = false,
            texture = 839977,

            handler = function ()
                applyBuff( 'stormkeeper', 20, 2 )
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
                if target.within10 then applyDebuff( 'target', 'thunderstorm' ) end
            end,
        },


        totem_mastery = {
            id = 210643,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            talent = 'totem_mastery',
            essential = true,

            startsCombat = false,
            texture = 511726,

            readyTime = function () return buff.totem_mastery.remains - 15 end,
            usable = function () return query_time - action.totem_mastery.lastCast > 3 end,
            handler = function ()
                applyBuff( 'resonance_totem', 120 )
                applyBuff( 'storm_totem', 120 )
                applyBuff( 'ember_totem', 120 )
                if buff.tailwind_totem.down then stat.spell_haste = stat.spell_haste + 0.02 end
                applyBuff( 'tailwind_totem', 120 )
                applyBuff( 'totem_mastery', 120 )
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
                applyBuff( 'water_walking' )
            end,
        },


        wind_rush_totem = {
            id = 192077,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = 'wind_rush_totem',

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

            toggle = 'interrupts',

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


    spec:RegisterPack( "Elemental", 20200802, [[deLGhcqib4rcfUKqrAtc0NuIQgfOYPaLwfQKELcXSekDlqr7Iu)sH0WucDmsWYqf8msittjkxtbY2qLOVHkKACkrLoNqrzDcfrVtOiqZtjY9uq7dvQ(hQqs1brLswOc4HOsPMOqr1fvGAJOsr9ruPigPqraNevkSsurVevijZKeQUjQqzNkb)eviXqrfILIkfPNkKPckCvLOIVkueAScfbDwuHKYEb5Vs1GfDyQwmQ6XszYq1LvTzL6ZK0Of0Pr61cvZg42kA3s(nKHRKooQq1Yr8CuMoX1HY2bv9DfQXtcLZlGwpQeMpjA)ugsbiyafH7YHwGdlYHfxC5Uih0CqbfXboWrdfjbUEOOvVf3vpuu5ZdfnyWNVehafT6bcqooemGIyims7qrHISYIjhDuvQeIXRBO5Om6ed4cfvnIVLrz0zBuOiEmkq4gfepueUlhAboSihwCXL7ICqZbfueh4axcfXwFdAboWLCakkKIJ)cIhkc)SguumSCWGpFjoWYOqF6LXzmSmuKvwm5OJQsLqmEDdnhLrNyaxOOQr8TmkJoBJACgdl5wyQymXsoeRLCyroSOXPXzmSKBh6L6zXKgNXWsyA5YHDlJjSFWNVehOXwTK4s4jwkHEzzl8T40s1YgcbWrJlMLcYs2VL0TLh85lXbmlDYT0Bcf(RnoJHLW0YyoL58GJB5GDIeA5GbF(sCGLVec9mTXzmSeMwYn9te83sUfR9c3R2TuOZp6akULTW3IRnoJHLW0sUfoULdoWBjABPeElJeezA5OwYXUCerBCgdlHPLCJsUkXLB5gRQdOLQL0sqwkH3sUfhrXTeU5jQNzjGYeML0YYggH8sSmIo52WQnoJHLW0sUfoULSlcTuzAM4T4DES9(elH3by3s4y)wYwFZs0Qqrfdwnu0kbTPGdffdlhm4ZxIdSmk0NEzCgdldfzLfto6OQujeJx3qZrz0jgWfkQAeFlJYOZ2OgNXWsUfMkgtSKdXAjhwKdlACACgdl52HEPEwmPXzmSeMwUCy3Yyc7h85lXbASvljUeEILsOxw2cFloTuTSHqaC04IzPGSK9BjDB5bF(sCaZsNCl9MqH)AJZyyjmTmMtzop44woyNiHwoyWNVehy5lHqptBCgdlHPLCt)eb)TKBXAVW9QDlf68JoGIBzl8T4AJZyyjmTKBHJB5Gd8wI2wkH3YibrMwoQLCSlhr0gNXWsyAj3OKRsC5wUXQ6aAPAjTeKLs4TKBXruClHBEI6zwcOmHzjTSSHriVelJOtUnSAJZyyjmTKBHJBj7IqlvMMjElENhBVpXs4Da2Teo2VLS13SeTkuuXGvBCACgdlhSI9gMCCl5)grULn0K3fl5VkTyAl5wT2xfMLfQGzOtMBmGLEtOOIzjQabQnoJHLEtOOIPxjVHM8UmCdCwCJZyyP3ekQy6vYBOjVlJmC0ncHBCgdl9MqrftVsEdn5DzKHJ6yQZxIluuzCgdlJkFLfIeljof3sES9(4wYexywY)nIClBOjVlwYFvAXS0lClxjhMRirOLQLuML4O6AJZyyP3ekQy6vYBOjVlJmCuw5RSqK0zIlmJtVjuuX0RK3qtExgz4Ocs(SpDMCsGgNXWsVjuuX0RK3qtExgz4O3jsy)GpFjoiw6EyaIdEj6vcD6G(bF(sCaLj6xop44gNgNXWYLd7wgjiYm()6jwUsEdn5DXsScCgZsgAElDCCMLJPaGLSvFCzjdHkTXP3ekQy6vYBOjVlJmCuMGiZ4)RNelDpuCWlrZeezg)F9e9lNhC8GWrCkE)W)s0ooot3qyLSKIuQK4u8(H)LODCCMMwCFqlcRXPXP3ekQy6vYBOjVlJmC0nL8(bF(sCqS09Waeh8s0mbrM9d(8L4a9lNhCCJtVjuuX0RK3qtExgz4OmbrM9d(8L4GyP7HIdEjAMGiZ(bF(sCG(LZdoUXP3ekQy6vYBOjVlJmC0vKqrLXP3ekQy6vYBOjVlJmC0d(8L4GopWzsS09qXbVe9bF(sCqNh4mr)Y5bh340Bcfvm9k5n0K3LrgokWH378yeMelDpmaXbVe9bF(sCqNh4mr)Y5bhpiB9aqxCI6fMUf60QdOQHsrl1LuKXP3ekQy6vYBOjVlJmC0wOtRoGQgkfTuJLUhYwpa0fNOEHPBHoT6aQAOu0sL7CW404mgwoyf7nm54wE4pjqlf68wkH3sVjiILuMLo8of48GRnoJHLCBNjwoaaHWbymXYPxyoaeOL0TLs4TKBXfNqLBjmiovSKBvTZeIdSKB6zOYR2TKYSCLC2lrBCgdl9MqrfBipaHWbymjw6EOZfNqLR9QDMqCqNCgQ8QD9lNhCCJZyyj3OGzdn5DXYvKqrLLuMLRKVp5LqDaiqlb0k(XTuqwgicJy5GbF(sCqSwIvGZyw2qtExSCmfaS8fULSqerabAC6nHIk2WvKqrvS09Wnvnu6KpDAXwIlxuPYgcbWrJlTkMtWPE1r7UZfNGKqn5tNwSLu0IgNXWsUrjNqWwflrBlBotyAJtVjuuXgz4OJPfENfENyC6nHIk2idhDd857SqulES09WaeAloTudYwpa0fNOEHPBHoT6aQAOu0sDPLfeUgcbWrJlntqKz)GpFjoqt(0PfBPgcbWrJlntqKz)GpFjoqJJrCHIkyQOfvQKhBV1JPfExfJjAM4T4lPWYG140BcfvSrgoQGKp7tNjNeyS09qXbVeTGKp7tNjNeO(LZdoEqES9wtodvE1ExqYNAYNoTylXbJtVjuuXgz4OyS3PYNmJtVjuuXgz4OBk59d(8L4GyP7Hbio4LOzcIm7h85lXb6xop44gNEtOOInYWrzcIm7h85lXbXs3dfh8s0mbrM9d(8L4a9lNhC8GWfG4GxIM2(gJeO(LZdoUsLbWJT3AA7BmsGAS1Gb0qiaoACPPTVXibQXwHniCbio4LODw7fUxTRF58GJRuzanecGJgxAN1EH7v7ASvynoJHLEtOOInYWrVtKW(bF(sCqS09Waeh8s0Re60b9d(8L4akt0VCEWXvQuCWlrVsOth0p4ZxIdOmr)Y5bhpiCBk59d(8L4anoACfmaXbVentqKz)GpFjoq)Y5bhxPsMGiZ(bF(sCGghnUcko4LOzcIm7h85lXb6xop44WAC6nHIk2idhTHQ2lH4YX7BGpVXP3ekQyJmCuEacH3r7Ue((Rpd040BcfvSrgoQkMtWPE1r7UZfNGKqJtVjuuXgz4OBudJD8UZfNqL35Vpno9MqrfBKHJUIrO7aPLANh4mX40BcfvSrgoQe(owXJWk8(grA340BcfvSrgo68tejWoA3bynkEhNCFYmo9MqrfBKHJsORRG3PvNT6TBC6nHIk2idhDmIaWH)0QtodvE1UXP3ekQyJmCuEacH33yKaJLUhgG4GxI2zTx4E1U(LZdoUsL8y7T2zTx4E1UgBvPYgcbWrJlTZAVW9QDn5tNwmUpOfno9MqrfBKHJYFc7K40snw6EyaIdEjAN1EH7v76xop44kvYJT3AN1EH7v7ASvJtVjuuXgz4OBk58aecpw6EyaIdEjAN1EH7v76xop44kvYJT3AN1EH7v7ASvLkBieahnU0oR9c3R21KpDAX4(Gw040BcfvSrgoQxTZeId6nhaILUhgG4GxI2zTx4E1U(LZdoUsL8y7T2zTx4E1UgBvPYgcbWrJlTZAVW9QDn5tNwmUpOfno9MqrfBKHJ(aFhT7s47mbrMXs3dzcIm7h85lXbAS1G8y7TU5aqhqvdLIwQAYNoTyCF4Y140BcfvSrgo68YreJtVjuuXgz4OeSQ7nHIQoGYKylF(Ho6Xs3d9MqH)9xFspJ7CiyaBSQoGwQgNEtOOInYWrjyv3BcfvDaLjXw(8dz0sf8U4e1lgNgNXWsoggqOwkor9ILEtOOYYvcfrOsGwcOmX40BcfvmTJ(qMGiZ4)RNelDpuCWlrZeezg)F9e9lNhCCJZyyz0k5oULCZaFElJcrT4wsllxAOLlZsXjQxSCtvdfwSwYJjwwiXsCmcTuTmAWwITk05JfRaNXSmqe2YtULBQAOqlvlvKLItuVWS0lCldD4VLGZywkHEzPclZYyI0c3sUjymXsM4T4mTXP3ekQyAh9rgo6g4Z3zHOw8yBb2aVlor9cBOcXs3djFtol05bpiCS1daDXjQxy6wOtRoGQgkfTuxcUbbZaeh8s0cs(SpDMCsG6xop44WQuzaIdEjAMGiZ(bF(sCG(LZdoEq42uY7h85lXbAYNoTyChofwgxzRha6HotoSkv2qiaoACP3uY7h85lXbAYNoTylbhhwgmvyzCLTEaOh6m5WclSbHlaXbVentqKz)GpFjoq)Y5bhxPsMGiZ(bF(sCGghnUuQKTEaOlor9ct3cDA1bu1qPOL6qffKhBV1JPfExfJjAM4T4lPWYG140BcfvmTJ(idh1zTx4E1ES09qXbVeTZAVW9QD9lNhC8GWjo4LOzcIm7h85lXb6xop44bzcIm7h85lXbAC04kydHa4OXLMjiYSFWNVehOjF60IXDfgKsLbio4LOzcIm7h85lXb6xop44WgeUaeh8s0023yKa1VCEWXvQmaES9wtBFJrcuJTgmGgcbWrJlnT9ngjqn2kSgNEtOOIPD0hz4OakhhJI3NU607cs(mw6EO4GxIgq54yu8(0vNExqYN6xop44gNgNXWsyqc0sbzPQpVLd2jsihhZJFlhtLql5yotoXs02sj8woyWNVeML8y7TLJdFz5MQgk0s1sfzP4e1lmTLXCuT8ILi4pP5RwYX8dycbndW40BcfvmTJ(idh9orc54yE8hlDpmaXbVe90zYjD0UlHVFWNVeM(LZdoULkvAjp2ERzcImJ)VEIgB1sLkTC6hWecAY9HWPWIlcZLXv26bGU4e1lmDl0PvhqvdLIwQWAPsLwYJT36PZKt6ODxcF)GpFjmn2QLkvAjB9aqxCI6fMUf60QdOQHsrlvURiJtVjuuX0o6JmC07ejKJJ5XFS09q4cqCWlrpDMCshT7s47h85lHPF58GJRujp2ERNotoPJ2Dj89d(8LW0yRkvYJT3AGdV3zye1RXrJlLkzRha6ItuVW03jsihhZJFUpCzWgeoES9wZeezg)F9en2QsLt)aMqqtUpeofwCryUmUYwpa0fNOEHPBHoT6aQAOu0sfwLk5X2B90zYjD0UlHVFWNVeMgBvPs26bGU4e1lmDl0PvhqvdLIwQCxrWACgdl5yE8BjdJCldeHzjoQwEXsaIDlDlJeezg)F9eTXP3ekQyAh9rgoAl0PvhqvdLIwQXs3d5X2BntqKz8)1t0KpDAXwsrCvTHZvES9wZeezg)F9ent8wCJtJZyyjhLceOLnNjwQ4o8ULdGryILOYsjK8BP4e1lmlPBlPILuMLEzjTyIxILEHBzKGitlhm4ZxIdSKYSCbokWWsVju4V240BcfvmTJ(idhf4W7DEmctILUhYJT3AGdV3zye1RXwdYwpa0fNOEHPBHoT6aQAOu0sDPLfeUaeh8s0mbrM9d(8L4a9lNhCCLkzcIm7h85lXbAC04c2G4irVb(8DwiQfxl0wCAPAC6nHIkM2rFKHJsBFJrcmw6EiB9aqxCI6fMUf60QdOQHsrl1LwwWa4X2BTZAVW9QDn2QXP3ekQyAh9rgo6MGysNfIAXJLUhYwpa0fNOEHPBHoT6aQAOu0sDPLfKhBV1023yKa1yRbdGhBV1oR9c3R21yRgNgNXWYLd7woyWNVehy5aaNjw6QoTyILyRwkilvKLItuVWS0zwcqLQLoZYibrMwoyWNVehyjLzzHel9MqH)AJtVjuuX0o6JmC0d(8L4GopWzsS09qXbVe9bF(sCqNh4mr)Y5bhpiB9aqxCI6fMUf60QdOQHsrl1Lwwq4cqCWlrZeez2p4ZxId0VCEWXvQKjiYSFWNVehOXrJlyno9Mqrft7OpYWrbo8EN)(mw6EO4GxI2zTx4E1U(LZdoUXP3ekQyAh9rgoAl0PvhqvdLIwQgNEtOOIPD0hz4OahEVZJrysSte80sDOcXs3dfh8s0oR9c3R21VCEWXno9Mqrft7OpYWr3aF(ole1Ih7ebpTuhQqSTaBG3fNOEHnuHyP7HKVjNf68GBC6nHIkM2rFKHJUjiM0zHOw8yNi4PL6qfmonoJHLX8VDmGyj3QjuuzjhHqreQeOLkoLjgNXWYyI3sCuT8IL1pULcYsg26kIiwU8W7eQZdUEJv1b0sD5TeMW0shhhvwg6mlx(nwvhql1L3sAjNuoaeySwY7SJBjQSKT(MLSlcTuzAJZyyP3ekQyAgTubVlor9Yq4Dc15bp2YNF4gRQdOLASW7aSp0Bcf(3F9j9mURqq4yRha6ItuVW0TqNwDavnukAPUehuQKTEaOlor9ctdC49o)95sCawJZyy5Glgg5wYnhzjLzP3ek83sScCgZYarywg6WFlvyzwIiworKBjt8wCMLOTLXePfULCtWyILBcAAzKGitlhm4ZxId0wc3GXvVLnN9yslXwBOjTuTKBXAwYJjw6nHc)TmAWXe0sCuT8ILWAC6nHIkMMrlvW7ItuVmCd857SqulESTaBG3fNOEHnuHyP7HWfGqBXPLQsLIdEjAMGiZ(bF(sCG(LZdoEWgcbWrJlntqKz)GpFjoqt(0PfBjoWv1gUsL4irVb(8DwiQfxt(0PfBPHQnCLkfh8s0oR9c3R21VCEWXdIJe9g4Z3zHOwCn5tNwSLGRHqaC04s7S2lCVAxt(0PfBeES9w7S2lCVAxJJrCHIkyd2qiaoACPDw7fUxTRjF60IT0YccxaIdEjAMGiZ(bF(sCG(LZdoUsLIdEjAMGiZ(bF(sCG(LZdoEqMGiZ(bF(sCGghnUGf2GWXJT36X0cVRIXent8w8Luyzkv6CXju5AQADegRVIKxc1bAIxX5(qoOujp2ERbo8ENHruVgBvPYa4X2BnpaHWbymrJTcBWa4X2BndJO(oA3xrJprJTACgdlxoSBj3I1EH7v7w6B5eldeHT8WFlzRVelDaWsf3H3TCamctSSf6e1ZS0lClrfiqlPBlRtLWtSmsqKPLdg85lXbwwiILCJ23yKaT0j3YggH8sabAP3ek8xBC6nHIkMMrlvW7ItuVmYWrDw7fUxThlDpuCWlr7S2lCVAx)Y5bhpydHa4OXLg4W7DEmct0KpDAX4(IbHJjiYSFWNVehOXrJlLkdqCWlrZeez2p4ZxId0VCEWXHniCbio4LOPTVXibQF58GJRuza8y7TM2(gJeOgBnyanecGJgxAA7BmsGASvynoJHLXCuT8ILySB5GbF(sCGLdaCMyjDBzGimlBimaULnNjw6wYXCMCILOTLs4TCWGpFjml)Cfn(KJB5GDIeAzuiQf3sAXK74AlJ5OA5flBotSCWGpFjoWYbaotSehJqlvlJeezA5GbF(sCGLyf4mMLbIWSm0H)wQifZYfCbJ4alJjGtMOkqTLdGjwsllLqkZYMZULmbTAjgJwQwoyWNVehy5aaNjwIQ2TmqeMLK7TqlvyzwYeVfNzjABzmrAHBj3emMOno9MqrftZOLk4DXjQxgz4Oh85lXbDEGZKyP7HIdEj6d(8L4GopWzI(LZdoEq4eh8s0tNjN0r7Ue((bF(sy6xop44b5X2B90zYjD0UlHVFWNVeMgBn40pGje0CjUCrLkdqCWlrpDMCshT7s47h85lHPF58GJdBq4caoMGiZ(bF(sCGgBnO4GxIMjiYSFWNVehOF58GJdRsLoxCcvUUCbJ4GEOtMOkqnXR4dvuqES9wpMw4DvmMOzI3IVKcldwJZyyjhv)RwgXrLLBeXsGtuVLiILmeQS0XXTCSd)zAlxof4mMLbIWSm0H)wgHruVLOTLCe04tI1sAz54qAl0YMZULbIWSCSxILcYsCegp4wYJT3wQ4u1qPOLQLdGaIL8bA5kcbOLQLCm)aMqqtl5)grEOx4AlhSI5ZvWTKDoo2R2JjTuHfxKJffRLdokwlJ4Okwlv8bI1sfh(bI1YbhfRLk(agNEtOOIPz0sf8U4e1lJmCuMGiZ4)RNelDpuCWlrZeezg)F9e9lNhC8GWrCkE)W)s0ooot3qyLSKIuQK4u8(H)LODCCMMwCFqlcBq4cqCWlrZWiQVJ29v04t0VCEWXvQKhBV1mmI67ODFfn(en2QsLt)aMqqtUpCzldwJtVjuuX0mAPcExCI6LrgokGYXXO49PRo9UGKpJLUhko4LObuoogfVpD1P3fK8P(LZdoEq4iofVF4FjAhhNPBiSswsrkvsCkE)W)s0ooottlUpOfH14mgwYTrtEADlJeezg)F9elhtLql5yotoXs02sj8woyWNVeMLiILrye1BjABjhbn(elXkWzmldeHzzOd)TucVLkUdVBzuiQf3sH4uXsVWTCIbe6k4wYeVfNfRLyf4mMLBSQoGwQAJtVjuuX0mAPcExCI6LrgokGQgkfTu78iGelDpmGnwvhql1G8y7TMjiYm()6jAS1GS1daDXjQxy6wOtRoGQgkfTuxIdbHZ5ItOY1ahEVZcrT4AIxX5kp2ERbo8ENfIAX1mXBXHDjoWLbHJhBV1tNjN0r7Ue((bF(syAS1Gbio4LOzye13r7(kA8j6xop44kvYJT3Aggr9D0UVIgFIgBfwJZyyzKpFSwYJjwoo8LLBSQoGwQXAzZzILk(awIvGZywkHNClDYTKlhXsXjQxyAJtVjuuX0mAPcExCI6LrgoAl0PvhqvdLIwQXs3d3yvDaTudYJT3AMGiZ4)RNOXwdcNZfNqLRbo8ENfIAX1eVIZvES9wdC49ole1IRzI3Id7skIldchp2ERNotoPJ2Dj89d(8LW0yRbdqCWlrZWiQVJ29v04t0VCEWXvQKhBV1mmI67ODFfn(en2kSgNXWsUX2YcjwUXQ6aAPgRLySB5GDIeYXX843s4pHHXSKdwkor9clwlXkWzmldeHzzOd)TuXD4DlJcrT4AlxoSB5GDIeYXX843s4pHHXSublfNOEXs62Yarywg6WFlHXBcQOnlHriwHFILkYsHopZsVWTCbokwgHruVLOTLCe04tS8LZdoULEHB5cCuSuXD4DlJcrT4AJtVjuuX0mAPcExCI6Lrgo6DIeYXX84pw6EyaBSQoGwQbHdo26bGU4e1lmDl0PvhqvdLIwQCxbLkDU4eQCT8MGkARlHyf(jAIxX5(qffmaXbVendJO(oA3xrJpr)Y5bhpOZfNqLRbo8ENfIAX1eVIVKcWg05ItOY1ahEVZcrT4AIxX5kp2ERbo8ENfIAX1mXBXxcofXLJOiU6CXju5A5nbv0wxcXk8t0eVIZv26bGU4e1lmDl0PvhqvdLIwQWgeUaeh8s0mmI67ODFfn(e9lNhCCLkdahj6nWNVZcrT4AY3KZcDEWvQKjiYSFWNVehOXwHniCbio4LONotoPJ2Dj89d(8LW0VCEWXvQKhBV1tNjN0r7Ue((bF(syASvLkBieahnU0ahEVZJryIM8Ptlg3xm40pGje0K7dJzCyefTixfh8s0nha6s47siwHFI(LZdooSWACgdl52otSCWorcTmke1IB5yQeAjhZzYjwI2wkH3Ybd(8LWSuCWlXsEmXYczP3ek83YimI6TeTTKJGgFIL8y7DSw6fULEtOWFlJeezg)F9el5X2Bl9c3sf3H3TCamctSSHM0s1s0EBj3oMB5yQesllLWBzDftSKBc3oMhRLEHB5Ps4jw6nHc)TKJ5m5elrBlLWB5GbF(sywYJT3XAjIyzHS0H3PaNhClvChE3YbWimXYXHuWTSUtSKJfzzZxJ1seXsgTub3sXjQxS0lClNyaHUcULkUdVBzuiQf3sH4uHzPx4wo9kqlzI3IZ0gNEtOOIPz0sf8U4e1lJmC07ejSZcrT4Xs3ddyJv1b0snya8y7TMHruFhT7ROXNOXwdko4LONotoPJ2Dj89d(8LW0VCEWXdchp2ERNotoPJ2Dj89d(8LW0yRkv2qiaoACPbo8ENhJWen5tNwmUVyWPFatiOj3hgZ4WikArUko4LOBoa0LW3LqSc)e9lNhCCLkzRha6ItuVW0TqNwDavnukAPUehccNZfNqLRbo8ENfIAX1eVIZvES9wdC49ole1IRzI3IVeh4sydYJT3AMGiZ4)RNOXwd2qiaoACPbo8ENhJWen5tNwSLgQ2WH14mgwg5ZBPZSCLC4PimwSwYJjwoMkHimXs4ih2w4BXPLQLCBf3sXjQxywooKcULBSQoGwQAJtVjuuX0mAPcExCI6Lrgo6DIe2zHOw8yP7HBSQoGwQbdGhBV1mmI67ODFfn(en2AqXbVe90zYjD0UlHVFWNVeM(LZdoEq44X2B90zYjD0UlHVFWNVeMgBvPYgcbWrJlnWH378yeMOjF60IX9fdo9dycbn5(WyghgrrlYvXbVeDZbGUe(UeIv4NOF58GJRujCoxCcvUg4W7DwiQfxt8kox5X2BnWH37SqulUMjEl(skIlHnip2ERzcImJ)VEIgBnydHa4OXLg4W7DEmct0KpDAXwAOAdhwJZyyj3gJqEjwoyWNVehyj3IJO4wogvlVyjg7wQ4oJHSCCifCl3yvDaTuJ1sgYsUXYpTKC26BcTuTucDXYWtU240BcfvmnJwQG3fNOEzKHJcOQHsrl1oWzmKXzmSKJAimlJxOXwoo0foQBj3WYqh3sgAElzHiIy5vSvGxUqrLLHNClrv7AlhatSucFzPeElBOcNkuuzPk5JJ1sVWTKByzOJBPGSKTcOILs4Tev3Yb7ej0YOqulULaADlPLGSCJWiATMHSmqeMLHo83sbzj(DGLJPsOLsiLzPZJM0YfkQSSqJJjTKB7mXYb7ej0YOqulULJPsictSKJ5m5elrBlLWB5GbF(sywko4LeRLEHB5yQeIWeldD4PLQLcHUcULCd16imMLCeK8sOoWsVWT0Bcf(Bj3I1EH7v7XAPx4w6nHc)TmsqKz8)1tSKhBVTerSSUtSKJfzzZxJ1seXYibrMwoyWNVehyjLzjT8MqH)XAPx4wo(w28A5flVIT(MyPGSu9ILEzPJJtfkQCGLySBjABzKGitlhm4ZxIdSKwwkH3sYNoTOLQLBQAOy5MGMwgHruVLOTLCe04t0gNEtOOIPz0sf8U4e1lJmC07ejSZcrT4Xs3ddqCWlrpDMCshT7s47h85lHPF58GJhma4CU4eQCnvTocJ1xrYlH6anXR4CNdb5X2BTZAVW9QDn2kSbHJhBV1mbrMX)xprJTQu50pGje0K7dJzloIIwKRIdEj6MdaDj8DjeRWpr)Y5bhxPYaGJjiYSFWNVehOXwdko4LOzcIm7h85lXb6xop44Wg8k26BYX7n0K3Lo4LQectHopmBieahnU0mbrM9d(8L4an5tNwmyQWGwKRBacrGdURyRVjhV3qtEx6GxQsimf68WSHqaC04sZeez2p4ZxId0KpDAXGnMQWGwewUpurlYv4uye4CU4eQC9BHOoA3LW3p4ZxIdyAIxX5(qoalSWACgdlxoSB5GDIeAzuiQf3s62YimI6TeTTKJGgFILuMLIdEjhpwl5XelRtLWtSKkwwiILULXCosKLdg85lXbwszw6nHc)T0flLWB5enFjXAPx4wQ4o8ULdGryILuMLK74bAjIy5ykayj)TKChpqlhtLqAzPeElRRyILCt42XCTXP3ekQyAgTubVlor9Yidh9orc7SqulES09qXbVendJO(oA3xrJpr)Y5bhpya8y7TMHruFhT7ROXNOXwd2qiaoACPbo8ENhJWen5tNwSLgQ2WdcxaIdEjAMGiZ(bF(sCG(LZdoEWaGBtjVFWNVehOXwHvPsXbVentqKz)GpFjoq)Y5bhpyaWXeez2p4ZxId0yRWcRXP3ekQyAgTubVlor9YidhfqvdLIwQDGZyOyP7H4irVb(8DwiQfxl0wCAPQuzdHa4OXLEd857SqulUM8PtlMXzmSKBSTSqILBSQoGwQXAjB1NwQ4u1qPOLQLdGacZsCmcTuTmsqKPLdg85lXbwIJrCHIQyTKUTmqeML4OA5fldD4VLCd16imMLCeK8sOoWseXYqh(BjvSevGaTevThRLEHBjoQwEXsm2TuXPQHsrlvlhabelXXi0s1YbaieoaJjws3wgicZYqh(BPBPI7W7wgHruVLCecQPno9MqrftZOLk4DXjQxgz4OaQAOu0sTZJasS09Wa2yvDaTudYeez2p4ZxId0yRbfh8s0mbrM9d(8L4a9lNhC8GW5CXju5AQADegRVIKxc1bAIxXxIdkvgap2ERbo8ENHruVgBnip2ER5bieoaJjASvynoJHLCJTLfsSCJv1b0snwlBotSuXPQHsrlvlhabeljx1j4GZywI2wkH3YvYHNIWyw2qfovOOYs62YarylpULae7w6wgjiYm()6jwYeVf3seXYqh(BzKGiZ4)RNyPx4wYXCMCILOTLs4TCWGpFjml9MqH)AJtVjuuX0mAPcExCI6LrgokGQgkfTu78iGelDpmGnwvhql1GWXJT3AMGiZ4)RNOjF60ITe7IqlvMMjElENhBVpHRQnCUYJT3AMGiZ4)RNOzI3IRujp2ERzcImJ)VEIgBnip2ERNotoPJ2Dj89d(8LW0yRWACgdl5gBl3yvDaTuJ1s2QpTKBh60YsfNQgkfTuTehJqlvlJeezA5GbF(sCGL4yexOOkwlPBldeHzjoQwEXYqh(Bj3qTocJzjhbjVeQdSerSm0H)wsflrfiqlrv7XAPx4wIJQLxSeJDlvCQAOu0s1YbqaXsCmcTuTCaacHdWyIL0TLbIWSm0H)w6wQ4o8ULrye1BjhHGAAJtVjuuX0mAPcExCI6LrgoAl0PvhqvdLIwQXs3d3yvDaTudYeez2p4ZxId0yRbfh8s0mbrM9d(8L4a9lNhC8GW5CXju5AQADegRVIKxc1bAIxXxIdkvgap2ERbo8ENHruVgBnip2ER5bieoaJjASvynoJHLCBNjwYTdDAzPItvdLIwQwsUQtWbNXSeTTucVLRKdpfHXSSHkCQqrLL0TLbIWwEClbi2T0TmsqKz8)1tSKjElULiILHo83YibrMX)xpXsVWTKJ5m5elrBlLWB5GbF(syw6nHc)1gNEtOOIPz0sf8U4e1lJmC0wOtRoGQgkfTuJLUhUXQ6aAPgeoES9wZeezg)F9en5tNwSLyxeAPY0mXBX78y79jCvTHZvES9wZeezg)F9ent8wCLk5X2BntqKz8)1t0yRb5X2B90zYjD0UlHVFWNVeMgBfwJZyy5YHDl5MjiMyzuiQf3YXuj0sUr7BmsGw6fULCmNjNyjABPeElhm4ZxctBC6nHIkMMrlvW7ItuVmYWr3eet6SqulES09qXbVenT9ngjq9lNhC8GIdEj6PZKt6ODxcF)GpFjm9lNhC8G8y7TM2(gJeOgBnip2ERNotoPJ2Dj89d(8LW0yRgNEtOOIPz0sf8U4e1lJmCuGdV35Ximjw6Eip2ERDw7fUxTRXwnoJHLlhHcOCXTmcJOElrBl5iOXNyPGSKTsUJBj3mWN3YOqulUL0TLtmGqxb3YxFspZsNClxjN9s0gNEtOOIPz0sf8U4e1lJmC0nWNVZcrT4X2cSbExCI6f2qfILUhs(MCwOZdEqVju4F)1N0Z4Ucb5X2BndJO(oA3xrJprJTACgdlxoSBPI7W7woagHjwoMkHwgHruVLOTLCe04tSKUTucVLaNjwUIKxc1bwIXC1BjABzKGitlhm4ZxIdSm0z1Ylw6wUXaalXXiUqrLLCu4MAjDBzGimlBimaULQxS0lKeEILymx9wI2wkH3YyohjYYbd(8L4alPBlLWBj5tNw0s1YnvnuSCSZSubUmMAjavQNOno9MqrftZOLk4DXjQxgz4OahEVZJrysS09qXbVentqKz)GpFjoq)Y5bhpydHa4OXvNCVjb5X2BndJO(oA3xrJprJTgeURyRVjhV3qtEx6GxQsimf68WSHqaC04sZeez2p4ZxId0KpDAXGPcdArUUbiebo4UIT(MC8Edn5DPdEPkHWuOZdZgcbWrJlntqKz)GpFjoqt(0Pfd2yQcdAryxsrlYv4uye4CU4eQC9BHOoA3LW3p4ZxIdyAIxX5(qoalSkvcNcAf4sUc3vS13KJ3BOjVlDWlvjeMcDEyHzdHa4OXLMjiYSFWNVehOjF60Ibtfg0ICDdqicCWPGwbUKRWDfB9n549gAY7sh8svcHPqNhwy2qiaoACPzcIm7h85lXbAYNoTyWgtvyqlclSlb3vS13KJ3BOjVlDWlvjeMcDEy2qiaoACPzcIm7h85lXbAYNoTyWuHbTix3aeIahCxXwFtoEVHM8U0bVuLqyk05HzdHa4OXLMjiYSFWNVehOjF60IbBmvHbTiSWcRXzmSC5WULkUdVB5ayeMy5yQeAzegr9wI2wYrqJpXs62sj8wcCMy5ksEjuhyjgZvVLOTLCZuYTCWGpFjoWYqNvlVyPB5gdaSehJ4cfvwYrHBQL0TLbIWSSHWa4wQEXsVqs4jwIXC1BjABPeElJ5CKilhm4ZxIdSKUTucVLKpDArlvl3u1qXYXoZsf4YyQLauPEI240BcfvmnJwQG3fNOEzKHJcC49opgHjXs3ddqCWlrZeez2p4ZxId0VCEWXd2qiaoAC1j3BsqES9wZWiQVJ29v04t0yRbH7k26BYX7n0K3Lo4LQectHopmBieahnU0Bk59d(8L4an5tNwmyQWGwKRBacrGdURyRVjhV3qtEx6GxQsimf68WSHqaC04sVPK3p4ZxId0KpDAXGnMQWGwe2Lu0ICfofgboNloHkx)wiQJ2Dj89d(8L4aMM4vCUpKdWcRsLWPGwbUKRWDfB9n549gAY7sh8svcHPqNhwy2qiaoACP3uY7h85lXbAYNoTyWuHbTix3aeIahCkOvGl5kCxXwFtoEVHM8U0bVuLqyk05HfMnecGJgx6nL8(bF(sCGM8PtlgSXufg0IWc7sWDfB9n549gAY7sh8svcHPqNhMnecGJgx6nL8(bF(sCGM8PtlgmvyqlY1naHiWb3vS13KJ3BOjVlDWlvjeMcDEy2qiaoACP3uY7h85lXbAYNoTyWgtvyqlclSWAC6nHIkMMrlvW7ItuVmYWrbu1qPOLANhbKyP7H8y7TMHruFhT7ROXNOXwno9MqrftZOLk4DXjQxgz4OahEVZJrysS09WgcbWrJRo5EtcgG4GxIE6m5KoA3LW3p4Zxct)Y5bh34mgwgbOQHciqlv95TKB0(gJeOL8y7TLcYYq063yaqGwYJT3wYqZB5NROXNCCl5MjiMyzuiQfNz5yQeAjhZzYjwI2wkH3Ybd(8LW0gNEtOOIPz0sf8U4e1lJmCuA7BmsGXs3dfh8s0023yKa1VCEWXdgaCt)aMqqtUZrpOGnecGJgxAGdV35Ximrt(0PfBPHlcBq4cqCWlrZeez2p4ZxId0VCEWXvQKjiYSFWNVehOXrJlyno9MqrftZOLk4DXjQxgz4OahEVZJrysS09WgcbWrJRo5Etc2cDI6zCxCWlr)wiQJ2Dj89d(8LW0VCEWXnoJHLraQAOac0s8d8aTeJrlvl5gTVXibA5NROXNCCl5MjiMyzuiQfNzPGS8Zv04tSuc)0YXuj0soMZKtSeTTucVLdg85lHzPGqAJtVjuuX0mAPcExCI6Lrgo6MGysNfIAXJLUhko4LOPTVXibQF58GJhKhBV1023yKa1yRb5X2BnT9ngjqn5tNwSLyxeAPY0mXBX78y79jCvTHZvES9wtBFJrcuZeVf340BcfvmnJwQG3fNOEzKHJcC49opgHjXs3dBieahnU6K7nX4mgwgZr1Ylw6Tgf)L4aqGwIXULrye1BjABjhbn(elhtLql5Mb(8wgfIAXTehJqlvlz0sfClfNOErBC6nHIkMMrlvW7ItuVmYWr3aF(ole1IhBlWg4DXjQxydviw6Ei5BYzHop4bdGhBV1mmI67ODFfn(en2QXP3ekQyAgTubVlor9YidhvqYN9PZKtcmw6EO4GxIwqYN9PZKtcu)Y5bhpiC8y7TMCgQ8Q9UGKp1KpDAXwIlvQeoES9wtodvE1ExqYNAYNoTylbhp2ERDw7fUxTRXXiUqr1inecGJgxAN1EH7v7AYNoTyWgSHqaC04s7S2lCVAxt(0PfBjfgeSWAC6nHIkMMrlvW7ItuVmYWr3eet6SqulES09qXbVenT9ngjq9lNhC8G8y7TM2(gJeOgBniC8y7TM2(gJeOM8Ptl2sQnCUUmUYJT3AA7BmsGAM4T4kvYJT3AMGiZ4)RNOXwvQmaXbVe90zYjD0UlHVFWNVeM(LZdooSgNXWsyeElX)2XaILr0j32sUfhrXTCmcdGBzHelBotSKBR4wooKcULBSQoGwQXAjpMy54Bz9JBjvSCJiwkor9IL4xEtOOYsVWTKJfPno9MqrftZOLk4DXjQxgz4OTqNwDavnukAPglDpKhBV1YBcQOTUeIv4NOXwdgap2ERzcImJ)VEIgBniB9aqxCI6fMUf60QdOQHsrlvURGXP3ekQyAgTubVlor9YidhfqvdLIwQDEeqmo9MqrftZOLk4DXjQxgz4OBGpFNfIAXJDIGNwQdvi2wGnW7ItuVWgQqS09qY3KZcDEWno9MqrftZOLk4DXjQxgz4OBGpFNfIAXJDIGNwQdviw6E4eb)NVenoLjE1o35sJZyyj3mbXelJcrT4wszwIWiworW)5lXYnfaorBC6nHIkMMrlvW7ItuVmYWr3eet6SqulESte80sDOcqrWFcJIkOf4WIkeZwC5QWIAoOWYgeu0yNu0sLbfXnMRiICClxMLEtOOYsaLjmTXjuKJjHicuueDIbCHIkUnX3cueGYegemGIy0sf8U4e1lqWaAbfGGbu0lNhCCObGI8Mqrfu0g4Z3zHOwCOOgHkNqDOi4SmalfAloTuTuPslfh8s0mbrM9d(8L4a9lNhCCldAzdHa4OXLMjiYSFWNVehOjF60Iz5swYbl5QLQnClvQ0sCKO3aF(ole1IRjF60Iz5sdTuTHBPsLwko4LODw7fUxTRF58GJBzqlXrIEd857SqulUM8PtlMLlzjCw2qiaoACPDw7fUxTRjF60Iz5iwYJT3AN1EH7v7ACmIluuzjSwg0YgcbWrJlTZAVW9QDn5tNwmlxYYLzzqlHZYaSuCWlrZeez2p4ZxId0VCEWXTuPslfh8s0mbrM9d(8L4a9lNhCCldAjtqKz)GpFjoqJJgxwcRLWAzqlHZsES9wpMw4DvmMOzI3IB5swQWYSuPslDU4eQCnvTocJ1xrYlH6anXR4wY9HwYblvQ0sES9wdC49odJOEn2QLkvAzawYJT3AEacHdWyIgB1syTmOLbyjp2ERzye13r7(kA8jASvOOwGnW7ItuVWGwqbibAboabdOOxop44qdaf1iu5eQdfjo4LODw7fUxTRF58GJBzqlBieahnU0ahEVZJryIM8PtlMLC3YfTmOLWzjtqKz)GpFjoqJJgxwQuPLbyP4GxIMjiYSFWNVehOF58GJBjSwg0s4Smalfh8s0023yKa1VCEWXTuPsldWsES9wtBFJrcuJTAzqldWYgcbWrJlnT9ngjqn2QLWcf5nHIkOiN1EH7v7qc0ckccgqrVCEWXHgakQrOYjuhksCWlrFWNVeh05bot0VCEWXTmOLWzP4GxIE6m5KoA3LW3p4Zxct)Y5bh3YGwYJT36PZKt6ODxcF)GpFjmn2QLbTC6hWecAA5swYLlAPsLwgGLIdEj6PZKt6ODxcF)GpFjm9lNhCClH1YGwcNLbyjCwYeez2p4ZxId0yRwg0sXbVentqKz)GpFjoq)Y5bh3syTuPslDU4eQCD5cgXb9qNmrvGAIxXTCOLkYYGwYJT36X0cVRIXent8wClxYsfwMLWcf5nHIkOOd(8L4GopWzcKaTWYGGbu0lNhCCObGIAeQCc1HIeh8s0mbrMX)xpr)Y5bh3YGwcNLeNI3p8VeTJJZ0newjwUKLkYsLkTK4u8(H)LODCCMMwwYDlh0IwcRLbTeoldWsXbVendJO(oA3xrJpr)Y5bh3sLkTKhBV1mmI67ODFfn(en2QLkvA50pGje00sUp0YLTmlHfkYBcfvqrmbrMX)xpbsGwyqqWak6LZdoo0aqrncvoH6qrIdEjAaLJJrX7txD6DbjFQF58GJBzqlHZsItX7h(xI2XXz6gcRelxYsfzPsLwsCkE)W)s0ooottll5ULdArlHfkYBcfvqrakhhJI3NU607cs(esGwGlHGbu0lNhCCObGIAeQCc1HIcWYnwvhqlvldAjp2ERzcImJ)VEIgB1YGwYwpa0fNOEHPBHoT6aQAOu0s1YLSKdwg0s4S05ItOY1ahEVZcrT4AIxXTKRwYJT3AGdV3zHOwCnt8wClH1YLSKdCPLbTeol5X2B90zYjD0UlHVFWNVeMgB1YGwgGLIdEjAggr9D0UVIgFI(LZdoULkvAjp2ERzye13r7(kA8jASvlHfkYBcfvqraQAOu0sTZJacKaTahnemGIE58GJdnauuJqLtOou0gRQdOLQLbTKhBV1mbrMX)xprJTAzqlHZsNloHkxdC49ole1IRjEf3sUAjp2ERbo8ENfIAX1mXBXTewlxYsfXLwg0s4SKhBV1tNjN0r7Ue((bF(syASvldAzawko4LOzye13r7(kA8j6xop44wQuPL8y7TMHruFhT7ROXNOXwTewOiVjuubf1cDA1bu1qPOLkKaTWYfcgqrVCEWXHgakQrOYjuhkkal3yvDaTuTmOLWzjCwYwpa0fNOEHPBHoT6aQAOu0s1sUBPcwQuPLoxCcvUwEtqfT1LqSc)enXR4wY9HwQildAzawko4LOzye13r7(kA8j6xop44wg0sNloHkxdC49ole1IRjEf3YLSublH1YGw6CXju5AGdV3zHOwCnXR4wYvl5X2BnWH37SqulUMjElULlzjCwQiU0YrSurwYvlDU4eQCT8MGkARlHyf(jAIxXTKRwYwpa0fNOEHPBHoT6aQAOu0s1syTmOLWzzawko4LOzye13r7(kA8j6xop44wQuPLbyjos0BGpFNfIAX1KVjNf68GBPsLwYeez2p4ZxId0yRwcRLbTeoldWsXbVe90zYjD0UlHVFWNVeM(LZdoULkvAjp2ERNotoPJ2Dj89d(8LW0yRwQuPLnecGJgxAGdV35Ximrt(0PfZsUB5Iwg0YPFatiOPLCFOLXmoy5iwQOfTKRwko4LOBoa0LW3LqSc)e9lNhCClH1syHI8Mqrfu0DIeYXX84hsGwiMbbdOOxop44qdaf1iu5eQdffGLBSQoGwQwg0YaSKhBV1mmI67ODFfn(en2QLbTuCWlrpDMCshT7s47h85lHPF58GJBzqlHZsES9wpDMCshT7s47h85lHPXwTuPslBieahnU0ahEVZJryIM8PtlMLC3YfTmOLt)aMqqtl5(qlJzCWYrSurlAjxTuCWlr3CaOlHVlHyf(j6xop44wQuPLS1daDXjQxy6wOtRoGQgkfTuTCjl5GLbTeolDU4eQCnWH37SqulUM4vCl5QL8y7Tg4W7DwiQfxZeVf3YLSKdCPLWAzql5X2BntqKz8)1t0yRwg0YgcbWrJlnWH378yeMOjF60Iz5sdTuTHBjSqrEtOOck6orc7SquloKaTGclcbdOOxop44qdaf1iu5eQdfTXQ6aAPAzqldWsES9wZWiQVJ29v04t0yRwg0sXbVe90zYjD0UlHVFWNVeM(LZdoULbTeol5X2B90zYjD0UlHVFWNVeMgB1sLkTSHqaC04sdC49opgHjAYNoTywYDlx0YGwo9dycbnTK7dTmMXblhXsfTOLC1sXbVeDZbGUe(UeIv4NOF58GJBPsLwcNLoxCcvUg4W7DwiQfxt8kULC1sES9wdC49ole1IRzI3IB5swQiU0syTmOL8y7TMjiYm()6jASvldAzdHa4OXLg4W7DEmct0KpDAXSCPHwQ2WTewOiVjuubfDNiHDwiQfhsGwqbfGGbuK3ekQGIau1qPOLAh4mgck6LZdoo0aqc0ckWbiyaf9Y5bhhAaOOgHkNqDOOaSuCWlrpDMCshT7s47h85lHPF58GJBzqldWs4S05ItOY1u16imwFfjVeQd0eVIBj3TKdwg0sES9w7S2lCVAxJTAjSwg0s4SKhBV1mbrMX)xprJTAPsLwo9dycbnTK7dTmMTOLJyPIw0sUAP4GxIU5aqxcFxcXk8t0VCEWXTuPsldWs4SKjiYSFWNVehOXwTmOLIdEjAMGiZ(bF(sCG(LZdoULWAzqlVIT(MC8Edn5DPdEPkHwctlf68wctlBieahnU0mbrM9d(8L4an5tNwmlHPLkmOfTKRwUbieXs4SeolVIT(MC8Edn5DPdEPkHwctlf68wctlBieahnU0mbrM9d(8L4an5tNwmlH1YyQLkmOfTewl5(qlv0IwYvlHZsfSCelHZsNloHkx)wiQJ2Dj89d(8L4aMM4vCl5(ql5GLWAjSwcluK3ekQGIUtKWole1IdjqlOGIGGbu0lNhCCObGIAeQCc1HIeh8s0mmI67ODFfn(e9lNhCCldAzawYJT3Aggr9D0UVIgFIgB1YGw2qiaoACPbo8ENhJWen5tNwmlxAOLQnCldAjCwgGLIdEjAMGiZ(bF(sCG(LZdoULbTmalHZYnL8(bF(sCGgB1syTuPslfh8s0mbrM9d(8L4a9lNhCCldAzawcNLmbrM9d(8L4an2QLWAjSqrEtOOck6orc7SquloKaTGcldcgqrVCEWXHgakQrOYjuhkchj6nWNVZcrT4AH2ItlvlvQ0YgcbWrJl9g4Z3zHOwCn5tNwmOiVjuubfbOQHsrl1oWzmeKaTGcdccgqrVCEWXHgakQrOYjuhkkal3yvDaTuTmOLmbrM9d(8L4an2QLbTuCWlrZeez2p4ZxId0VCEWXTmOLWzPZfNqLRPQ1ryS(ksEjuhOjEf3YLSKdwQuPLbyjp2ERbo8ENHruVgB1YGwYJT3AEacHdWyIgB1syHI8MqrfueGQgkfTu78iGajqlOaxcbdOOxop44qdaf1iu5eQdffGLBSQoGwQwg0s4SKhBV1mbrMX)xprt(0PfZYLSKDrOLktZeVfVZJT3NyjxTuTHBjxTKhBV1mbrMX)xprZeVf3sLkTKhBV1mbrMX)xprJTAzql5X2B90zYjD0UlHVFWNVeMgB1syHI8MqrfueGQgkfTu78iGajqlOahnemGIE58GJdnauuJqLtOou0gRQdOLQLbTKjiYSFWNVehOXwTmOLIdEjAMGiZ(bF(sCG(LZdoULbTeolDU4eQCnvTocJ1xrYlH6anXR4wUKLCWsLkTmal5X2BnWH37mmI61yRwg0sES9wZdqiCagt0yRwcluK3ekQGIAHoT6aQAOu0sfsGwqHLlemGIE58GJdnauuJqLtOou0gRQdOLQLbTeol5X2BntqKz8)1t0KpDAXSCjlzxeAPY0mXBX78y79jwYvlvB4wYvl5X2BntqKz8)1t0mXBXTuPsl5X2BntqKz8)1t0yRwg0sES9wpDMCshT7s47h85lHPXwTewOiVjuubf1cDA1bu1qPOLkKaTGcXmiyaf9Y5bhhAaOOgHkNqDOiXbVenT9ngjq9lNhCCldAP4GxIE6m5KoA3LW3p4Zxct)Y5bh3YGwYJT3AA7BmsGASvldAjp2ERNotoPJ2Dj89d(8LW0yRqrEtOOckAtqmPZcrT4qc0cCyriyaf9Y5bhhAaOOgHkNqDOiES9w7S2lCVAxJTcf5nHIkOiGdV35XimbsGwGdkabdOOxop44qdaf5nHIkOOnWNVZcrT4qrncvoH6qrKVjNf68GBzql9MqH)9xFspZsUBPcwg0sES9wZWiQVJ29v04t0yRqrTaBG3fNOEHbTGcqc0cCGdqWak6LZdoo0aqrncvoH6qrIdEjAMGiZ(bF(sCG(LZdoULbTSHqaC04QtU3eldAjp2ERzye13r7(kA8jASvldAjCwEfB9n549gAY7sh8svcTeMwk05TeMw2qiaoACPzcIm7h85lXbAYNoTywctlvyqlAjxTCdqiILWzjCwEfB9n549gAY7sh8svcTeMwk05TeMw2qiaoACPzcIm7h85lXbAYNoTywcRLXulvyqlAjSwUKLkArl5QLWzPcwoILWzPZfNqLRFle1r7Ue((bF(sCatt8kULCFOLCWsyTewlvQ0s4SubTcCPLC1s4S8k26BYX7n0K3Lo4LQeAjmTuOZBjSwctlBieahnU0mbrM9d(8L4an5tNwmlHPLkmOfTKRwUbieXs4SeolvqRaxAjxTeolVIT(MC8Edn5DPdEPkHwctlf68wcRLW0YgcbWrJlntqKz)GpFjoqt(0PfZsyTmMAPcdArlH1syTCjlHZYRyRVjhV3qtEx6GxQsOLW0sHoVLW0YgcbWrJlntqKz)GpFjoqt(0PfZsyAPcdArl5QLBacrSeolHZYRyRVjhV3qtEx6GxQsOLW0sHoVLW0YgcbWrJlntqKz)GpFjoqt(0PfZsyTmMAPcdArlH1syTewOiVjuubfbC49opgHjqc0cCqrqWak6LZdoo0aqrncvoH6qrbyP4GxIMjiYSFWNVehOF58GJBzqlBieahnU6K7nXYGwYJT3Aggr9D0UVIgFIgB1YGwcNLxXwFtoEVHM8U0bVuLqlHPLcDElHPLnecGJgx6nL8(bF(sCGM8PtlMLW0sfg0IwYvl3aeIyjCwcNLxXwFtoEVHM8U0bVuLqlHPLcDElHPLnecGJgx6nL8(bF(sCGM8PtlMLWAzm1sfg0IwcRLlzPIw0sUAjCwQGLJyjCw6CXju563crD0UlHVFWNVehW0eVIBj3hAjhSewlH1sLkTeolvqRaxAjxTeolVIT(MC8Edn5DPdEPkHwctlf68wcRLW0YgcbWrJl9MsE)GpFjoqt(0PfZsyAPcdArl5QLBacrSeolHZsf0kWLwYvlHZYRyRVjhV3qtEx6GxQsOLW0sHoVLWAjmTSHqaC04sVPK3p4ZxId0KpDAXSewlJPwQWGw0syTewlxYs4S8k26BYX7n0K3Lo4LQeAjmTuOZBjmTSHqaC04sVPK3p4ZxId0KpDAXSeMwQWGw0sUA5gGqelHZs4S8k26BYX7n0K3Lo4LQeAjmTuOZBjmTSHqaC04sVPK3p4ZxId0KpDAXSewlJPwQWGw0syTewlHfkYBcfvqrahEVZJrycKaTahwgemGIE58GJdnauuJqLtOouep2ERzye13r7(kA8jASvOiVjuubfbOQHsrl1opciqc0cCyqqWak6LZdoo0aqrncvoH6qrnecGJgxDY9MyzqldWsXbVe90zYjD0UlHVFWNVeM(LZdoouK3ekQGIao8ENhJWeibAboWLqWak6LZdoo0aqrncvoH6qrIdEjAA7BmsG6xop44wg0YaSeolN(bmHGMwYDl5OhKLbTSHqaC04sdC49opgHjAYNoTywU0qlx0syTmOLWzzawko4LOzcIm7h85lXb6xop44wQuPLmbrM9d(8L4anoACzjSqrEtOOckI2(gJeiKaTah4OHGbu0lNhCCObGIAeQCc1HIAieahnU6K7nXYGw2cDI6zwYDlfh8s0VfI6ODxcF)GpFjm9lNhCCOiVjuubfbC49opgHjqc0cCy5cbdOOxop44qdaf1iu5eQdfjo4LOPTVXibQF58GJBzql5X2BnT9ngjqn2QLbTKhBV1023yKa1KpDAXSCjlzxeAPY0mXBX78y79jwYvlvB4wYvl5X2BnT9ngjqnt8wCOiVjuubfTjiM0zHOwCibAboeZGGbu0lNhCCObGIAeQCc1HIAieahnU6K7nbkYBcfvqrahEVZJrycKaTGIwecgqrVCEWXHgakYBcfvqrBGpFNfIAXHIAeQCc1HIiFtol05b3YGwgGL8y7TMHruFhT7ROXNOXwHIAb2aVlor9cdAbfGeOfuKcqWak6LZdoo0aqrncvoH6qrIdEjAbjF2Notojq9lNhCCldAjCwYJT3AYzOYR27cs(ut(0PfZYLSKlTuPslHZsES9wtodvE1ExqYNAYNoTywUKLWzjp2ERDw7fUxTRXXiUqrLLJyzdHa4OXL2zTx4E1UM8PtlMLWAzqlBieahnU0oR9c3R21KpDAXSCjlvyqwcRLWcf5nHIkOibjF2NotojqibAbfXbiyaf9Y5bhhAaOOgHkNqDOiXbVenT9ngjq9lNhCCldAjp2ERPTVXibQXwTmOLWzjp2ERPTVXibQjF60Iz5swQ2WTKRwUml5QL8y7TM2(gJeOMjElULkvAjp2ERzcImJ)VEIgB1sLkTmalfh8s0tNjN0r7Ue((bF(sy6xop44wcluK3ekQGI2eet6SquloKaTGIueemGIE58GJdnauuJqLtOouep2ERL3eurBDjeRWprJTAzqldWsES9wZeezg)F9en2QLbTKTEaOlor9ct3cDA1bu1qPOLQLC3sfGI8Mqrfuul0PvhqvdLIwQqc0ckAzqWakYBcfvqraQAOu0sTZJacu0lNhCCObGeOfu0GGGbu0ebpTuHwqbOOxop49jcEAPcnauK3ekQGI2aF(ole1Idf1cSbExCI6fg0ckaf1iu5eQdfr(MCwOZdou0lNhCCObGeOfuexcbdOOxop44qdaf9Y5bVprWtlvObGIAeQCc1HIMi4)8LOXPmXR2TK7wYLqrEtOOckAd857Squlou0ebpTuHwqbibAbfXrdbdOOjcEAPcTGcqrVCEW7te80sfAaOiVjuubfTjiM0zHOwCOOxop44qdajqcuKJoemGwqbiyaf9Y5bhhAaOOgHkNqDOiXbVentqKz8)1t0VCEWXHI8MqrfuetqKz8)1tGeOf4aemGIE58GJdnauK3ekQGI2aF(ole1Idf1iu5eQdfr(MCwOZdULbTeolzRha6ItuVW0TqNwDavnukAPA5swcNLdYsyAzawko4LOfK8zF6m5Ka1VCEWXTewlvQ0YaSuCWlrZeez2p4ZxId0VCEWXTmOLWz5MsE)GpFjoqt(0PfZsUBjCwQWYSKRwYwpa0dDMClH1sLkTSHqaC04sVPK3p4ZxId0KpDAXSCjlHZsoSmlHPLkSml5QLS1da9qNj3syTewlH1YGwcNLbyP4GxIMjiYSFWNVehOF58GJBPsLwYeez2p4ZxId04OXLLkvAjB9aqxCI6fMUf60QdOQHsrlvlhAPISmOL8y7TEmTW7QymrZeVf3YLSuHLzjSqrTaBG3fNOEHbTGcqc0ckccgqrVCEWXHgakQrOYjuhksCWlr7S2lCVAx)Y5bh3YGwcNLIdEjAMGiZ(bF(sCG(LZdoULbTKjiYSFWNVehOXrJlldAzdHa4OXLMjiYSFWNVehOjF60Izj3TuHbzPsLwgGLIdEjAMGiZ(bF(sCG(LZdoULWAzqlHZYaSuCWlrtBFJrcu)Y5bh3sLkTmal5X2BnT9ngjqn2QLbTmalBieahnU0023yKa1yRwcluK3ekQGICw7fUxTdjqlSmiyaf9Y5bhhAaOOgHkNqDOiXbVenGYXXO49PRo9UGKp1VCEWXHI8MqrfueGYXXO49PRo9UGKpHeOfgeemGIE58GJdnauuJqLtOouuawko4LONotoPJ2Dj89d(8LW0VCEWXTuPsl5X2BntqKz8)1t0yRwQuPLt)aMqqtl5(qlHZsfwCrlHPLlZsUAjB9aqxCI6fMUf60QdOQHsrlvlH1sLkTKhBV1tNjN0r7Ue((bF(syASvlvQ0s26bGU4e1lmDl0PvhqvdLIwQwYDlveuK3ekQGIUtKqooMh)qc0cCjemGIE58GJdnauuJqLtOoueCwgGLIdEj6PZKt6ODxcF)GpFjm9lNhCClvQ0sES9wpDMCshT7s47h85lHPXwTuPsl5X2BnWH37mmI614OXLLkvAjB9aqxCI6fM(orc54yE8Bj3hA5YSewldAjCwYJT3AMGiZ4)RNOXwTuPslN(bmHGMwY9HwcNLkS4IwctlxMLC1s26bGU4e1lmDl0PvhqvdLIwQwcRLkvAjp2ERNotoPJ2Dj89d(8LW0yRwQuPLS1daDXjQxy6wOtRoGQgkfTuTK7wQilHfkYBcfvqr3jsihhZJFibAboAiyaf9Y5bhhAaOOgHkNqDOiES9wZeezg)F9en5tNwmlxYsfzjxTuTHBjxTKhBV1mbrMX)xprZeVfhkYBcfvqrTqNwDavnukAPcjqlSCHGbu0lNhCCObGIAeQCc1HI4X2BnWH37mmI61yRwg0s26bGU4e1lmDl0PvhqvdLIwQwUKLlZYGwcNLbyP4GxIMjiYSFWNVehOF58GJBPsLwYeez2p4ZxId04OXLLWAzqlXrIEd857SqulUwOT40sfkYBcfvqrahEVZJrycKaTqmdcgqrVCEWXHgakQrOYjuhkITEaOlor9ct3cDA1bu1qPOLQLlz5YSmOLbyjp2ERDw7fUxTRXwHI8MqrfueT9ngjqibAbfwecgqrVCEWXHgakQrOYjuhkITEaOlor9ct3cDA1bu1qPOLQLlz5YSmOL8y7TM2(gJeOgB1YGwgGL8y7T2zTx4E1UgBfkYBcfvqrBcIjDwiQfhsGwqbfGGbu0lNhCCObGIAeQCc1HIeh8s0h85lXbDEGZe9lNhCCldAjB9aqxCI6fMUf60QdOQHsrlvlxYYLzzqlHZYaSuCWlrZeez2p4ZxId0VCEWXTuPslzcIm7h85lXbAC04YsyHI8Mqrfu0bF(sCqNh4mbsGwqboabdOOxop44qdaf1iu5eQdfjo4LODw7fUxTRF58GJdf5nHIkOiGdV35VpHeOfuqrqWakYBcfvqrTqNwDavnukAPcf9Y5bhhAaibAbfwgemGIE58GJdnau0lNh8(ebpTuHgakQrOYjuhksCWlr7S2lCVAx)Y5bhhkYBcfvqrahEVZJrycu0ebpTuHwqbibAbfgeemGIMi4PLk0ckaf9Y5bVprWtlvObGI8Mqrfu0g4Z3zHOwCOOwGnW7ItuVWGwqbOOgHkNqDOiY3KZcDEWHIE58GJdnaKaTGcCjemGIMi4PLk0ckaf9Y5bVprWtlvObGI8Mqrfu0MGysNfIAXHIE58GJdnaKajqr4F7yabcgqlOaemGIE58GJdnauuJqLtOou0MQgkDYNoTywUKLC5IwQuPLnecGJgxAvmNGt9QJ2DNlobjHAYNoTywUKLkArOiVjuubfTIekQGeOf4aemGI8Mqrfu0yAH3zH3jqrVCEWXHgasGwqrqWak6LZdoo0aqrncvoH6qrbyPqBXPLQLbTKTEaOlor9ct3cDA1bu1qPOLQLlz5YSmOLWzzdHa4OXLMjiYSFWNVehOjF60Iz5sw2qiaoACPzcIm7h85lXbACmIluuzjmTurlAPsLwYJT36X0cVRIXent8wClxYsfwMLWcf5nHIkOOnWNVZcrT4qc0cldcgqrVCEWXHgakQrOYjuhksCWlrli5Z(0zYjbQF58GJBzql5X2Bn5mu5v7DbjFQjF60Iz5swYbOiVjuubfji5Z(0zYjbcjqlmiiyaf5nHIkOim27u5tgu0lNhCCObGeOf4siyaf9Y5bhhAaOOgHkNqDOOaSuCWlrZeez2p4ZxId0VCEWXHI8Mqrfu0MsE)GpFjoasGwGJgcgqrVCEWXHgakQrOYjuhksCWlrZeez2p4ZxId0VCEWXTmOLWzzawko4LOPTVXibQF58GJBPsLwgGL8y7TM2(gJeOgB1YGwgGLnecGJgxAA7BmsGASvlH1YGwcNLbyP4GxI2zTx4E1U(LZdoULkvAzaw2qiaoACPDw7fUxTRXwTewOiVjuubfXeez2p4ZxIdGeOfwUqWakYBcfvqrnu1EjexoEFd85HIE58GJdnaKaTqmdcgqrEtOOckIhGq4D0UlHV)6ZaHIE58GJdnaKaTGclcbdOiVjuubfPI5eCQxD0U7CXjijek6LZdoo0aqc0ckOaemGI8Mqrfu0g1WyhV7CXju5D(7tOOxop44qdajqlOahGGbuK3ekQGIwXi0DG0sTZdCMaf9Y5bhhAaibAbfueemGI8MqrfuKe(owXJWk8(grAhk6LZdoo0aqc0ckSmiyaf5nHIkOO5NisGD0UdWAu8oo5(Kbf9Y5bhhAaibAbfgeemGI8MqrfueHUUcENwD2Q3ou0lNhCCObGeOfuGlHGbuK3ekQGIgJiaC4pT6KZqLxTdf9Y5bhhAaibAbf4OHGbu0lNhCCObGIAeQCc1HIcWsXbVeTZAVW9QD9lNhCClvQ0sES9w7S2lCVAxJTAPsLw2qiaoACPDw7fUxTRjF60Izj3TCqlcf5nHIkOiEacH33yKaHeOfuy5cbdOOxop44qdaf1iu5eQdffGLIdEjAN1EH7v76xop44wQuPL8y7T2zTx4E1UgBfkYBcfvqr8NWojoTuHeOfuiMbbdOOxop44qdaf1iu5eQdffGLIdEjAN1EH7v76xop44wQuPL8y7T2zTx4E1UgB1sLkTSHqaC04s7S2lCVAxt(0PfZsUB5GwekYBcfvqrBk58aechsGwGdlcbdOOxop44qdaf1iu5eQdffGLIdEjAN1EH7v76xop44wQuPL8y7T2zTx4E1UgB1sLkTSHqaC04s7S2lCVAxt(0PfZsUB5GwekYBcfvqrE1otioO3CaasGwGdkabdOOxop44qdaf1iu5eQdfXeez2p4ZxId0yRwg0sES9w3CaOdOQHsrlvn5tNwml5(qlxUqrEtOOck6b(oA3LW3zcImHeOf4ahGGbuK3ekQGIMxoIaf9Y5bhhAaibAboOiiyaf9Y5bhhAaOOgHkNqDOiVju4F)1N0ZSK7wYbldAzawUXQ6aAPcf5nHIkOicw19MqrvhqzcueGYKE5Zdf5OdjqlWHLbbdOOxop44qdaf5nHIkOicw19MqrvhqzcueGYKE5ZdfXOLk4DXjQxGeibkAL8gAY7cemGwqbiyaf5nHIkOibjF2NotojqOOxop44qdajqlWbiyaf9Y5bhhAaOOgHkNqDOiXbVentqKz8)1t0VCEWXTmOLWzjXP49d)lr744mDdHvILlzPISuPsljofVF4FjAhhNPPLLC3YbTOLWcf5nHIkOiMGiZ4)RNajqlOiiyaf9Y5bhhAaOOgHkNqDOOaSuCWlrZeez2p4ZxId0VCEWXHI8Mqrfu0MsE)GpFjoasGwyzqWak6LZdoo0aqrncvoH6qrIdEjAMGiZ(bF(sCG(LZdoouK3ekQGIycIm7h85lXbqc0cdccgqrEtOOckAfjuubf9Y5bhhAaibAbUecgqrVCEWXHgakQrOYjuhksCWlrFWNVeh05bot0VCEWXHI8Mqrfu0bF(sCqNh4mbsGwGJgcgqrVCEWXHgakQrOYjuhkkalfh8s0h85lXbDEGZe9lNhCCldAjB9aqxCI6fMUf60QdOQHsrlvlxYsfbf5nHIkOiGdV35XimbsGwy5cbdOOxop44qdaf1iu5eQdfXwpa0fNOEHPBHoT6aQAOu0s1sUBjhGI8Mqrfuul0PvhqvdLIwQqcKajqcKabb]] )


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

end
