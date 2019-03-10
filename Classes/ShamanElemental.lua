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

                local up = buff.resonance_totem.up and remains > 0

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
        for i = 1, 5 do
            local hasTotem, name = GetTotemInfo( i )

            if name == class.abilities.totem_mastery.name and hasTotem ~= up then
                ScrapeUnitAuras( "player" )
                return
            end
        end

        local hasTotemAura = FindUnitBuffByID( "player", 210652 ) ~= nil
        if hasTotemAura ~= hadTotemAura then ScrapeUnitAuras( "player" ) end
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


        bloodlust = {
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
            cooldown = 150,
            recharge = 150,
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

            spend = 0.2,
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
            cooldown = 150,
            recharge = 150,
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

            startsCombat = true,
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
            -- texture = ,

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


    spec:RegisterPack( "Elemental", 20190310.0122, [[d8uWPbqisjpsiLlbvj2KuPpbvugfi5uGuRsi4vkKMLuHBjv0Ui5xkedti5ykLwguHNjKQPPGQRrkLTPGIVbvu14uQk15GQuwNsvfVdQOcnpLQCpfyFqvCqHqzHkipuiKAIkOuxKuQ2OsvL(iurLgjurfCsHq1kvQ8sHqsZeQs1nvQk2Psr)uiKyOqvslvPQKEkPAQkfUQck5RkvLySqfv0Ev0FvYGfDyklgPESGjdLlRAZG6Zc1OLQonQEnuPzdCBPSBj)gYWbXXfcXYr8CuMoX1rY2fI(Uc14HkY5HQA9kvvnFsX(P6525gtDmt(CtCe1w8wurFBuQO2IdCGJOp1f8H8PoelGRf)PEzTp11o4TxIbM6qm8bidBUXuNHOiHp17fbcB)mYiXCPNIwfqTry8gfWeoQcedwgHXBHrM60uCGeXRj9uhZKp3ehrTfVfv03gLkQT4yR2WXuNb5H5M4yyWXuVNJH9Asp1Xolm1JMNAh82lXaEQ3BnR8DrZZErGW2pJmsmx6POvbuBegVrbmHJQaXGLry8wyeFx08CFmsO3ZTr1HN4iQT4np70ZO2UFWXwFNVlAEgr3Bv8z7hFx08StphwS7joNRdE7LyaffepjM0FINsVvEg6FaxEf7zaHayOXfZtb5j73toSNh82lXampnY90ccpYR8DrZZo9CyZzgn4yEQDJi9EQDWBVed45lHWpt57IMND65(6BOiVNrmw4fMvH7PWBFKHW7Eg6FaxLVlAE2PNrmmmp1o(3teSNs)9uxqKMNJ45(C5iIAQdHGG5Gp1JMNAh82lXaEQ3BnR8DrZZErGW2pJmsmx6POvbuBegVrbmHJQaXGLry8wyeFx08CFmsO3ZTr1HN4iQT4np70ZO2UFWXwFNVlAEgr3Bv8z7hFx08StphwS7joNRdE7LyaffepjM0FINsVvEg6FaxEf7zaHayOXfZtb5j73toSNh82lXampnY90ccpYR8DrZZo9CyZzgn4yEQDJi9EQDWBVed45lHWpt57IMND65(6BOiVNrmw4fMvH7PWBFKHW7Eg6FaxLVlAE2PNrmmmp1o(3teSNs)9uxqKMNJ45(C5iIY357IMNAhNEGsoMN0hgrUNbuJ2epPFmVykpJyHWHimplu1zVrAWuapTGWrfZtubWx57SGWrftbH8aQrBYayGXW13zbHJkMcc5buJ2KrhmcmcH57SGWrftbH8aQrBYOdgXOIBVet4OY357IMN6LbH1JepjghZtAky4J5jtmH5j9HrK7za1OnXt6hZlMNwH5jeY7ecseEf7jN5jgQUY3zbHJkMcc5buJ2KrhmcRmiSEKSyIjmFNfeoQykiKhqnAtgDWicsEB1mMCc((oliCuXuqipGA0Mm6GrUrK(1bV9smqhC4bAjg4LOGq4ndSo4TxIb4mr9YObhZ357IMNdl29uxqKgU)qoXtiKhqnAt8KQaNX8KHA3tddJ55yoa4jdInU8KHqLY3zbHJkMcc5buJ2KrhmctqKgU)qoPdo8aXaVeftqKgU)qor9YObhRlueJJTEKVeLHHXubevj7fDnAighB9iFjkddJP4fE0wuq778Dwq4OIPGqEa1Onz0bJaZjFDWBVed0bhEGwIbEjkMGiT1bV9smG6LrdoMVZcchvmfeYdOgTjJoyeMGiT1bV9smqhC4bIbEjkMGiT1bV9smG6LrdoMVZcchvmfeYdOgTjJoyeiiHJkFNfeoQykiKhqnAtgDWih82lXalAGXKo4Wded8suh82lXalAGXe1lJgCmFNfeoQykiKhqnAtgDWialsBrtryshC4bAjg4LOo4TxIbw0aJjQxgn4yDzqoaSeJeFHPc9gVwaECVu8kEVO77SGWrftbH8aQrBYOdgj0B8Ab4X9sXR4o4WdyqoaSeJeFHPc9gVwaECVu8kgp4W357IMNAhNEGsoMNpYtW3tH3UNs)90ccI4jN5PfPXbgn4kFx08mI2yINdbqimaft8SzfLba47jh2tP)EgX2)t4Y9CdIXfpJyv4mHyap3xpdvwfUNCMNqiN9su(oliCuXgqdqimaft6GdpW2)t4YvwfotigyrodvwfU6LrdoMVZ3fnpJ4vNbuJ2epHGeoQ8KZ8ec5WN8s4gaGVNaEH7X8uqEIpII4P2bV9smqhEsvGZyEgqnAt8Cmha88fMNSEera477SGWrfB0bJabjCu1bhEWXjipihBfqnAtwGxXsFNcV99IEuA0aZjFDWBVedOOGOrdtqK26G3EjgqrbX357IMNr8soHqbr8eb7zWyct57SGWrfB0bJmMxylw)nIVZ3zbHJk2OdgrqYBRMXKtWVdo8aXaVeLGK3wnJjNGV6LrdowxAkyyf5muzv4lbjVPiVz8ITho8Dwq4OIn6GrG5KVo4TxIb6GdpqlXaVeftqK26G3Ejgq9YObhZ3zbHJk2OdgHjisBDWBVed0bhEGyGxIIjisBDWBVedOEz0GJ1fkTed8su8WHPi4REz0GJPrJw0uWWkE4Wue8vuq6QvaHayOXLIhomfbFffeO7cLwIbEjkJfEHzv4Qxgn4yA0OvaHayOXLYyHxywfUIcsxTOPGHvgl8cZQWvuqG23fnpTGWrfB0bJCJi9RdE7LyGo4Wd0smWlrbHWBgyDWBVedWzI6LrdoMgnIbEjkieEZaRdE7LyaotuVmAWX6cvaHayOXLcMt(6G3EjgqrEZ4fBVT4iQUAjg4LOycI0wh82lXaQxgn4yA0eqiagACPycI0wh82lXakYBgVy7Tfhr1vmWlrXeePTo4TxIbuVmAWXG23zbHJk2OdgHI9fxEJ57SGWrfB0bJqdqiSfmfb)o4Wd0smWlrzSWlmRcx9YObhtJgAkyyLXcVWSkCffenAcieadnUugl8cZQWvK3mEXWJ2IY3zbHJk2OdgH(e2j4YR4o4Wd0smWlrzSWlmRcx9YObhtJgAkyyLXcVWSkCffeFNfeoQyJoyeyo50aecRdo8aTed8sugl8cZQWvVmAWX0OHMcgwzSWlmRcxrbrJMacbWqJlLXcVWSkCf5nJxm8OTO8Dwq4OIn6GrSkCMqmWkyaqhC4bAjg4LOmw4fMvHREz0GJPrdnfmSYyHxywfUIcIgnbecGHgxkJfEHzv4kYBgVy4rBr57SGWrfB0bJC8)cbVK(VycI06GdpGjisBDWBVedOOG0LMcgwfmayb4X9sXRyf5nJxm8myF77SGWrfB0bJ0UCeX3zbHJk2OdgHqvlliCuTaCM0rzTpWqVdo8ali8i)61B8ZWdo6cfdYbGLyK4lmvO341cWJ7LIxX4bhA0WGCayjgj(ctbSiTf9TgEWb0(oliCuXgDWieQAzbHJQfGZKokR9bmEfd(sms8fFNVlAEUpuaH7PyK4lEAbHJkpHq4icxW3taNj(oliCuXug6dycI0W9hYjDWHhig4LOycI0W9hYjQxgn4y(oFx08uhc5gMN7xG1UN69OaUEYlp3BGNd3tXiXx8eMh3lSo8KMs8SqINyueEf7PU29KcIWBVdQcCgZt8ru4mY9eMh3l8k2ZO7PyK4lmpTcZZElY7j4mMNsVvEUD4EUVWlmpX5sXepzIfWLP8Dwq4OIPm0hDWiWaR9fRhfWTJa(bWxIrIVWgSTdo8aYHjN1B0G3fkgKdalXiXxyQqVXRfGh3lfVI3dkT1PwIbEjkbjVTAgtobF1lJgCmO1OrlXaVeftqK26G3Ejgq9YObhRluWCYxh82lXakYBgVy4bQTdpcmihaw9gto0A0eqiagACPG5KVo4TxIbuK3mEX2dkCm8o3o8iWGCay1Bm5qdn0DHslXaVeftqK26G3Ejgq9YObhtJgMGiT1bV9smGcdnU0OHb5aWsms8fMk0B8Ab4X9sXR4brVlnfmSAmVWwXumrXelG7EBho0(oliCuXug6JoyeJfEHzv4DWHhig4LOmw4fMvHREz0GJ1fkXaVeftqK26G3Ejgq9YObhRltqK26G3EjgqHHgxDdieadnUumbrARdE7Lyaf5nJxm8SvBA0OLyGxIIjisBDWBVedOEz0GJbDxO0smWlrXdhMIGV6LrdoMgnArtbdR4HdtrWxrbPRwbecGHgxkE4Wue8vuqG23zbHJkMYqF0bJa4reko2QzXnBji5To4Wded8suaEeHIJTAwCZwcsEt9YObhZ357IMNBqW3tb5zS1UNA3isFeHYW9EoMl9EUpgtoXteSNs)9u7G3EjmpPPGH9CC)lpH5X9cVI9m6Ekgj(ct55Wgv4mXtuKNemiEUp2bmHGAA57SGWrftzOp6GrUrK(icLH77GdpqlXaVevZyYjle8s6)6G3Ejm1lJgCmnAOPGHvmbrA4(d5effenAA2bmHGA4zauBJkQohEeyqoaSeJeFHPc9gVwaECVu8kgAnAOPGHvnJjNSqWlP)RdE7LWuuq0OHb5aWsms8fMk0B8Ab4X9sXRy8eDFNVlAEUpgU3tgf5EIpIYtmuHZepbi2908uxqKgU)qor57SGWrftzOp6Grc9gVwaECVu8kUdo8aAkyyftqKgU)qorrEZ4fBVOhH4aweOPGHvmbrA4(d5eftSaU(oFx08mIsbW3ZGXepX7wKMNdrryINOYtPN87PyK4lmp5WEYfp5mpTYtEXeRepTcZtDbrAEQDWBVed4jN55Mru2Wtli8iVY3zbHJkMYqF0bJaSiTfnfHjDWHhqtbdRawK2IrrIVIcsxgKdalXiXxyQqVXRfGh3lfVI3B4DHslXaVeftqK26G3Ejgq9YObhtJgMGiT1bV9smGcdnUGUlgsuWaR9fRhfWvj8aU8k23zbHJkMYqF0bJWdhMIGFhC4bmihawIrIVWuHEJxlapUxkEfV3W7QfnfmSYyHxywfUIcIVZcchvmLH(OdgbMGyYI1Jc42bhEadYbGLyK4lmvO341cWJ7LIxX7n8U0uWWkE4Wue8vuq6QfnfmSYyHxywfUIcIVZ3fnphwS7P2bV9smGNdbmM4PfB8IjEsbXtb5z09ums8fMNgZtaQI90yEQlisZtTdE7Lyap5mplK4PfeEKx57SGWrftzOp6Gro4TxIbw0aJjDWHhig4LOo4TxIbw0aJjQxgn4yDzqoaSeJeFHPc9gVwaECVu8kEVH3fkTed8sumbrARdE7Lya1lJgCmnAycI0wh82lXakm04cAFNfeoQykd9rhmcWI0w03ADWHhig4LOmw4fMvHREz0GJ57SGWrftzOp6Grc9gVwaECVu8k23zbHJkMYqF0bJaSiTfnfHjD0qrYR4bB7GdpqmWlrzSWlmRcx9YObhZ3zbHJkMYqF0bJadS2xSEua3oAOi5v8GTDeWpa(sms8f2GTDWHhqom5SEJgCFNfeoQykd9rhmcmbXKfRhfWTJgksEfpyRVZ3fnp15vm4EUHrIV4zeliCu5jELWreUGVN4Dot8DrZtTxmkY9C)Q7jN5PfeEK3tQcCgZt8ruE2BrEp3oCprepBiY9KjwaxMNiyp3x4fMN4CPyINWeuZtDbrAEQDWBVedO8ekTJfFpdg77hpPGeqnEf7zeJf8KMs80ccpY7PU2X5ONyOcNjEcTVZcchvmfJxXGVeJeFzamWAFX6rbC7GdpakTeEaxEfRrJyGxIIjisBDWBVedOEz0GJ1nGqam04sXeePTo4TxIbuK3mEX2dhrioGPrdgsuWaR9fRhfWvrEZ4fBVbXbmnAed8sugl8cZQWvVmAWX6IHefmWAFX6rbCvK3mEX2dQacbWqJlLXcVWSkCf5nJxSrPPGHvgl8cZQWvyuet4Oc6UbecGHgxkJfEHzv4kYBgVy7n8UqPLyGxIIjisBDWBVedOEz0GJPrJyGxIIjisBDWBVedOEz0GJ1nGqam04sXeePTo4TxIbuK3mEX2BloIcAO7cfnfmSAmVWwXumrXelG7EBhUgn2(FcxUIhxhrXwqqYlHBafXkCXZaCOrdnfmScyrAlgfj(kkiA0OfnfmSIgGqyakMOOGaDxTOPGHvmks8xi4fe04tuuq8D(UO55WIDpJySWlmRc3tdwoXt8ru4SiVNmiVepnaWt8UfP55queM4zO3iXN5PvyEIka(EYH9Sox6pXtDbrAEQDWBVed4zHiEgXdhMIGVNg5EgOiKxcaFpTGWJ8kFNfeoQykgVIbFjgj(YOdgXyHxywfEhC4bIbEjkJfEHzv4Qxgn4yDdieadnUualsBrtryII8MXlgEIQlubecGHgxkMGiT1bV9smGI8MXl2EBXruA0OLyGxIIjisBDWBVedOEz0GJbDxO0smWlrXdhMIGV6LrdoMgnArtbdR4HdtrWxrbPRwbecGHgxkE4Wue8vuqG2357IMNdBuHZepPy3tTdE7LyaphcymXtoSN4JO8mGOayEgmM4P55(ym5eprWEk93tTdE7LW88niOXNCmp1UrKEp17rbC9Kxm5gMYZHnQWzINbJjEQDWBVed45qaJjEIrr4vSN6cI08u7G3EjgWtQcCgZt8ruE2BrEpJoo55MMqrmGN4CWinuHVYZHOep5LNspN5zWy3tMGG4jfJxXEQDWBVed45qaJjEIQW9eFeLNKBHEp3oCpzIfWL5jc2Z9fEH5joxkMO8Dwq4OIPy8kg8LyK4lJoyKdE7LyGfnWyshC4bIbEjQdE7LyGfnWyI6LrdowxOed8sunJjNSqWlP)RdE7LWuVmAWX6stbdRAgtozHGxs)xh82lHPOG0TzhWecQT3WeLgnAjg4LOAgtozHGxs)xh82lHPEz0GJbDxO0ckMGiT1bV9smGIcsxXaVeftqK26G3Ejgq9YObhdAnAS9)eUCvzcfXaREJ0qf(kIv4oi6DPPGHvJ5f2kMIjkMybC3B7WH2357IMNru)H4PEevpHrepbgj(EIiEYqOYtddZZXwKNP8CyvGZyEIpIYZElY7Pofj(EIG9eVIgFshEYlph3Zd9Egm29eFeLNJTs8uqEIHOOb3tAkyypX784EP4vSNdHaIN047jeecWRyp3h7aMqqnpPpmI8ERWuEQDCYAqa3t2JiuVcF)452OIAF07WtTR3HN6ru7Wt8(qD4jEpYH6WtTR3HN49H8Dwq4OIPy8kg8LyK4lJoyeMGinC)HCshC4bIbEjkMGinC)HCI6LrdowxOighB9iFjkddJPciQs2l6A0qmo26r(sugggtXl8OTOGUluAjg4LOyuK4VqWliOXNOEz0GJPrdnfmSIrrI)cbVGGgFIIcIgnn7aMqqn8my4dhAFNVZcchvmfJxXGVeJeFz0bJa4reko2QzXnBji5To4Wded8suaEeHIJTAwCZwcsEt9YObhRlueJJTEKVeLHHXubevj7fDnAighB9iFjkddJP4fE0wuq778DrZZiAuJMx3tDbrA4(d5ephZLEp3hJjN4jc2tP)EQDWBVeMNiIN6uK47jc2t8kA8jkFNfeoQykgVIbFjgj(YOdgbWJ7LIxXlAeq6GdpGMcgwXeePH7pKtuuq6YGCayjgj(ctf6nETa84EP4v8E4Olu0uWWQMXKtwi4L0)1bV9sykkiD1smWlrXOiXFHGxqqJpr9YObhtJgAkyyfJIe)fcEbbn(effeO9D(UO55g9NCpB84EXZaQDpTYtkiyMCpHrepLEoZtaVUNJ5sVNmu7EQJWREcqX8GY3zbHJkMIXRyWxIrIVm6GrUrK(icLH77GdpGb5aWsms8fMk0B8Ab4X9sXRy8STluAjg4LOyuK4VqWliOXNOEz0GJPrJwyirbdS2xSEuaxf5WKZ6nAW1OHjisBDWBVedOOGaDxO0smWlr1mMCYcbVK(Vo4Txct9YObhtJgAkyyvZyYjle8s6)6G3EjmffenAA2bmHGA4zaEdhq778DrZZ9fU075(ym5eprWEk93tTdE7LW8eFeLNbR8eccb8CFSdycb18KcINcYZ9TN7JDatiOMN0hGg7P0FpdgepfKNVyuK7jxyEsXUNJ5sVNA3isVN69OaUkph2OcNjEII8KXeUCp1PiX3teSN4v04t8KMcgMP8mIJZAEcqiC5vSNM4j(ikpJyWYjSEuaxT8Dwq4OIPy8kg8LyK4lJoyKBePFX6rbC7GdpqlAkyyfJIe)fcEbbn(effKUIbEjQMXKtwi4L0)1bV9syQxgn4yDHIMcgw1mMCYcbVK(Vo4TxctrbrJMacbWqJlfWI0w0ueMOiVz8IHNO62Sdycb1WZa8gogn6rfbXaVevWaGL0)L0tvyNOEz0GJPrdnfmSIjisd3FiNOOG0nGqam04sbSiTfnfHjkYBgVy7nioGbTVZ3fnp3x4spIs8CFmMCINiypL(7P2bV9syD4jf7EQDJi9EQ3Jc4655s)jEYH9uxqKgU)qoXtoZtkiD45(yhWecQ5jN55yU0Zlp3gLN7JDatiOMNiypL(7zWG0HNiINNl9N4PUGinp1o4TxIb8KZkCM4PyGxYX8er8Kl4mMNfs80ccpY7PvyEIpII4jWyIN6cI08u7G3EjgWteSNs)9eMh3lEoMdaE2BrEprfaFpnpHyeHBapXOiMWrLNqbbqX8u6VNAp0J8eb7P0Fp1o4TxIbyEIrrmHJkOvEgXH9eFeLN9wK3ZiECDefZt8ksEjCd4z09u4TZ6WtmuHZepPy3tTBePN1Jc46jgfHxXEgXyHxywfUY3zbHJkMIXRyWxIrIVm6GrUrK(fRhfWTdo8aTed8sunJjNSqWlP)RdE7LWuVmAWX6Qfu2(FcxUIhxhrXwqqYlHBafXkCXdo6stbdRmw4fMvHROGaDxOOPGHvmbrA4(d5effenAA2bmHGA4zaElQrJEurqmWlrfmayj9Fj9uf2jQxgn4yA0OfumbrARdE7LyaffKUIbEjkMGiT1bV9smG6Lrdog0Dpob5b5yRaQrBYc8kw67u4T3zaHayOXLIjisBDWBVedOiVz8I15wTfveGbiebkOoob5b5yRaQrBYc8kw67u4T3zaHayOXLIjisBDWBVedOiVz8IbnEzR2IcA8mi6rfbO2oku2(FcxU6HE0cbVK(Vo4TxIbykIv4INb4aAOH2357IMNdl29u7gr69uVhfW1toSN6uK47jc2t8kA8jEYzEkg4LCSo8KMs8Sox6pXtU4zHiEAEoSXR6EQDWBVed4jN5PfeEK3tt8u6VNnu7L0HNwH5jE3I08Cikct8KZ8KCddFprephZbapPVNKBy475yU0ZlpL(7zDCs8eNBe9Ww57SGWrftX4vm4lXiXxgDWi3is)I1Jc42bhEGyGxIIrrI)cbVGGgFI6LrdowxTOPGHvmks8xi4fe04tuuq6gqiagACPawK2IMIWef5nJxS9gehW6cLwIbEjkMGiT1bV9smG6LrdowxTG5KVo4TxIbuuq0OrmWlrXeePTo4TxIbuVmAWX6QftqK26G3EjgqrbbAFNVlAEQdXAEI35X9sXRyphcbeMNyueEf7PUGinp1o4TxIb8eJIychvEYH9eFeLNyOcNjE2BrEpJ4X1rumpXRi5LWnGNiIN9wK3tU4jQa47jQcVdpTcZtmuHZepPy3t8opUxkEf75qiG4jgfHxXEoeaHWaumXtoSN4JO8S3I8EAEI3Tinp1PiX3t8kbfu(olWfuXumEfd(sms8f2OdgbWJ7LIxXlAeq6GdpGjisBDWBVedOOG0vmWlrXeePTo4TxIbuVmAWX6cLT)NWLR4X1ruSfeK8s4gqrSc39WHgnArtbdRawK2IrrIVIcsxAkyyfnaHWaumrrbX357IMNdl29C)sqmXt9EuaxphZLEpJ4HdtrW3tRW8CFmMCINiypL(7P2bV9sykFNfeoQykgVIbFjgj(YOdgbMGyYI1Jc42bhEGyGxIIhomfbF1lJgCSUIbEjQMXKtwi4L0)1bV9syQxgn4yDPPGHv8WHPi4ROG0LMcgw1mMCYcbVK(Vo4TxctrbX357SGWrftX4vm4lXiXxgDWialsBrtryshC4b0uWWkJfEHzv4kki(oFx08CyjCaF)VN6uK47jc2t8kA8jEkipzqi3W8C)cS29uVhfW1toSNnkGWHaUNVEJFMNg5EcHC2lr57SGWrftX4vm4lXiXxgDWiWaR9fRhfWTJa(bWxIrIVWgSTdo8aYHjN1B0G31ccpYVE9g)m8STlnfmSIrrI)cbVGGgFIIcIVZ3fnphwS7jE3I08Cikct8Cmx69uNIeFprWEIxrJpXtoSNs)9eymXtii5LWnGNuml(EIG908uxqKMNAh82lXaE2BScNjEAEctbaEIrrmHJkpJOSV6jh2t8ruEgquampJV4PviP)epPyw89eb7P0Fph24vDp1o4TxIb8Kd7P0FpjVz8IxXEcZJ7fphBmp3om4fpbOk(eLVZcchvmfJxXGVeJeFz0bJaSiTfnfHjDWHhig4LOycI0wh82lXaQxgn4yDdieadnUwKBbPlnfmSIrrI)cbVGGgFIIcsxOoob5b5yRaQrBYc8kw67u4T3zaHayOXLIjisBDWBVedOiVz8I15wTfveGbiebkOoob5b5yRaQrBYc8kw67u4T3zaHayOXLIjisBDWBVedOiVz8IbnEzR2Ic69IEuraQTJcLT)NWLREOhTqWlP)RdE7LyaMIyfU4zaoGgAnAGARA7WebOoob5b5yRaQrBYc8kw67u4TdDNbecGHgxkMGiT1bV9smGI8MXlwNB1wuragGqeOGARA7WebOoob5b5yRaQrBYc8kw67u4TdDNbecGHgxkMGiT1bV9smGI8MXlg04LTAlkOHEpOoob5b5yRaQrBYc8kw67u4T3zaHayOXLIjisBDWBVedOiVz8I15wTfveGbiebkOoob5b5yRaQrBYc8kw67u4T3zaHayOXLIjisBDWBVedOiVz8IbnEzR2IcAOH2357IMNdl29eVBrAEoefHjEoMl9EQtrIVNiypXROXN4jh2tP)EcmM4jeK8s4gWtkMfFprWEAEUF5K7P2bV9smGN9gRWzINMNWuaGNyuet4OYZik7REYH9eFeLNbefaZZ4lEAfs6pXtkMfFprWEk93ZHnEv3tTdE7Lyap5WEk93tYBgV4vSNW84EXZXgZZTddEXtaQIpr57SGWrftX4vm4lXiXxgDWialsBrtryshC4bAjg4LOycI0wh82lXaQxgn4yDdieadnUwKBbPlnfmSIrrI)cbVGGgFIIcsxOoob5b5yRaQrBYc8kw67u4T3zaHayOXLcMt(6G3EjgqrEZ4fRZTAlQiadqicuqDCcYdYXwbuJ2Kf4vS03PWBVZacbWqJlfmN81bV9smGI8MXlg04LTAlkO3l6rfbO2oku2(FcxU6HE0cbVK(Vo4TxIbykIv4INb4aAO1ObQTQTdteG64eKhKJTcOgTjlWRyPVtH3o0DgqiagACPG5KVo4TxIbuK3mEX6CR2IkcWaeIafuBvBhMia1XjipihBfqnAtwGxXsFNcVDO7mGqam04sbZjFDWBVedOiVz8IbnEzR2IcAO3dQJtqEqo2kGA0MSaVIL(ofE7DgqiagACPG5KVo4TxIbuK3mEX6CR2IkcWaeIafuhNG8GCSva1OnzbEfl9Dk827mGqam04sbZjFDWBVedOiVz8IbnEzR2IcAOH2357SGWrftX4vm4lXiXxgDWiaECVu8kErJashC4b0uWWkgfj(le8ccA8jkki(oliCuXumEfd(sms8LrhmcWI0w0ueM0bhEqaHayOX1ICliD1smWlr1mMCYcbVK(Vo4Txct9YObhZ35PN(UO5PoGh3la89m2A3ZiE4Wue89KMcg2tb5zpcYHPaa89KMcg2tgQDpFdcA8jhZZ9lbXep17rbCzEoMl9EUpgtoXteSNs)9u7G3EjmLVZcchvmfJxXGVeJeFz0bJWdhMIGFhC4bIbEjkE4Wue8vVmAWX6Qfun7aMqqn8GZRTUbecGHgxkGfPTOPimrrEZ4fBVbrbDxO0smWlrXeePTo4TxIbuVmAWX0OjGqam04sXeePTo4TxIbuK3mEX2BloIcAFNVZcchvmfJxXGVeJeFz0bJaSiTfnfHjDWHheqiagACTi3cs3qVrIpdpIbEjQh6rle8s6)6G3Ejm1lJgCmFNVlAEQd4X9caFpXoWW3tkgVI9mIhomfbFpFdcA8jhZZ9lbXep17rbCzEkipFdcA8jEk9V55yU075(ym5eprWEk93tTdE7LW8uqiLVZcchvmfJxXGVeJeFz0bJatqmzX6rbC7GdpqmWlrXdhMIGV6LrdowxAkyyfpCykc(kkiDPPGHv8WHPi4RiVz8IT3w12iehWIanfmSIhomfbFftSaU(oFNfeoQykgVIbFjgj(YOdgbyrAlAkct6GdpiGqam04ArUfeFNVlAEoSrfot80cbo2lXaa89KIDp1PiX3teSN4v04t8Cmx69C)cS29uVhfW1tmkcVI9KXRyW9ums8fLVZcchvmfJxXGVeJeFz0bJadS2xSEua3oc4haFjgj(cBW2o4WdihMCwVrdExTOPGHvmks8xi4fe04tuuq8Dwq4OIPy8kg8LyK4lJoyebjVTAgtob)o4Wded8sucsEB1mMCc(Qxgn4yDHIMcgwrodvwf(sqYBkYBgVy7nmA0afnfmSICgQSk8LGK3uK3mEX2dkAkyyLXcVWSkCfgfXeoQgnGqam04szSWlmRcxrEZ4fd6UbecGHgxkJfEHzv4kYBgVy7TvBqdTVZ3zbHJkMIXRyWxIrIVm6GrGjiMSy9OaUDWHhig4LO4HdtrWx9YObhRlnfmSIhomfbFffKUqrtbdR4HdtrWxrEZ4fBV4awegEeOPGHv8WHPi4RyIfWvJgAkyyftqKgU)qorrbrJgTed8sunJjNSqWlP)RdE7LWuVmAWXG23zbHJkMIXRyWxIrIVm6Gra84EP4v8IgbeFNfeoQykgVIbFjgj(YOdgbgyTVy9OaUD0qrYR4bB7iGFa8LyK4lSbB7GdpGCyYz9gn4(oliCuXumEfd(sms8LrhmcmWAFX6rbC7OHIKxXd22bhEqdf5BVefgNjwfoEggFNVlAEUFjiM4PEpkGRNCMNikINnuKV9s8eMdaNO8Dwq4OIPy8kg8LyK4lJoyeycIjlwpkGBhnuK8kEW2PEKNW4OAUjoIAlElkCe1(wTnQOp1hBKIxXSPEeVbbrKJ55W90cchvEc4mHP8DtDaNjS5gtDgVIbFjgj(YCJ5MBNBm1Fz0GJnhAQhiC5eUn1HYtT8u4bC5vSNA04PyGxIIjisBDWBVedOEz0GJ5zxpdieadnUumbrARdE7Lyaf5nJxmp3ZtC4ze8moG5PgnEIHefmWAFX6rbCvK3mEX8CVbEghW8uJgpfd8sugl8cZQWvVmAWX8SRNyirbdS2xSEuaxf5nJxmp3ZtO8mGqam04szSWlmRcxrEZ4fZZr9KMcgwzSWlmRcxHrrmHJkpH2ZUEgqiagACPmw4fMvHRiVz8I55EEoCp76juEQLNIbEjkMGiT1bV9smG6LrdoMNA04PyGxIIjisBDWBVedOEz0GJ5zxpdieadnUumbrARdE7Lyaf5nJxmp3ZZT4ikpH2tO9SRNq5jnfmSAmVWwXumrXelGRN7552H7PgnEA7)jC5kECDefBbbjVeUbueRW1t8mWtC4PgnEstbdRawK2IrrIVIcINA04PwEstbdRObiegGIjkkiEcTND9ulpPPGHvmks8xi4fe04tuuqM6wq4OAQddS2xSEua3Pm3ehZnM6VmAWXMdn1deUCc3M6IbEjkJfEHzv4Qxgn4yE21ZacbWqJlfWI0w0ueMOiVz8I5jE8mkp76juEgqiagACPycI0wh82lXakYBgVyEUNNBXruEQrJNA5PyGxIIjisBDWBVedOEz0GJ5j0E21tO8ulpfd8su8WHPi4REz0GJ5PgnEQLN0uWWkE4Wue8vuq8SRNA5zaHayOXLIhomfbFffepHEQBbHJQPUXcVWSk8Pm3m6ZnM6VmAWXMdn1deUCc3M6IbEjQdE7LyGfnWyI6LrdoMND9ekpfd8sunJjNSqWlP)RdE7LWuVmAWX8SRN0uWWQMXKtwi4L0)1bV9sykkiE21ZMDatiOMN755WeLNA04PwEkg4LOAgtozHGxs)xh82lHPEz0GJ5j0E21tO8ulpHYtMGiT1bV9smGIcIND9umWlrXeePTo4TxIbuVmAWX8eAp1OXtB)pHlxvMqrmWQ3inuHVIyfUEoWZO7zxpPPGHvJ5f2kMIjkMybC9Cpp3oCpHEQBbHJQP(bV9smWIgymzkZnh(CJP(lJgCS5qt9aHlNWTPUyGxIIjisd3FiNOEz0GJ5zxpHYtIXXwpYxIYWWyQaIQep3ZZO7PgnEsmo26r(sugggtXlpXJNAlkpH2ZUEcLNA5PyGxIIrrI)cbVGGgFI6LrdoMNA04jnfmSIrrI)cbVGGgFIIcINA04zZoGjeuZt8mWZHpCpHEQBbHJQPotqKgU)qozkZn12CJP(lJgCS5qt9aHlNWTPUyGxIcWJiuCSvZIB2sqYBQxgn4yE21tO8KyCS1J8LOmmmMkGOkXZ98m6EQrJNeJJTEKVeLHHXu8Yt84P2IYtON6wq4OAQd4reko2QzXnBji5TPm3CyMBm1Fz0GJnhAQhiC5eUn1PPGHvmbrA4(d5effep76jdYbGLyK4lmvO341cWJ7LIxXEUNN4WZUEcLN0uWWQMXKtwi4L0)1bV9sykkiE21tT8umWlrXOiXFHGxqqJpr9YObhZtnA8KMcgwXOiXFHGxqqJprrbXtON6wq4OAQd4X9sXR4fncitzUjo)CJP(lJgCS5qt9aHlNWTPodYbGLyK4lmvO341cWJ7LIxXEIhp36zxpHYtT8umWlrXOiXFHGxqqJpr9YObhZtnA8ulpXqIcgyTVy9OaUkYHjN1B0G7PgnEYeePTo4TxIbuuq8eAp76juEQLNIbEjQMXKtwi4L0)1bV9syQxgn4yEQrJN0uWWQMXKtwi4L0)1bV9sykkiEQrJNn7aMqqnpXZapXB4WtON6wq4OAQFJi9rekd3pL5M775gt9xgn4yZHM6bcxoHBtDT8KMcgwXOiXFHGxqqJprrbXZUEkg4LOAgtozHGxs)xh82lHPEz0GJ5zxpHYtAkyyvZyYjle8s6)6G3Ejmffep1OXZacbWqJlfWI0w0ueMOiVz8I5jE8mkp76zZoGjeuZt8mWt8go8CupJEuEgbpfd8subdaws)xspvHDI6LrdoMNA04jnfmSIjisd3FiNOOG4zxpdieadnUualsBrtryII8MXlMN7nWZ4aMNqp1TGWr1u)gr6xSEua3Pm3eVn3yQ)YObhBo0upq4YjCBQRLNIbEjQMXKtwi4L0)1bV9syQxgn4yE21tT8ekpT9)eUCfpUoIITGGKxc3akIv46jE8ehE21tAkyyLXcVWSkCffepH2ZUEcLN0uWWkMGinC)HCIIcINA04zZoGjeuZt8mWt8wuEoQNrpkpJGNIbEjQGbalP)lPNQWor9YObhZtnA8ulpHYtMGiT1bV9smGIcIND9umWlrXeePTo4TxIbuVmAWX8eAp765XjipihBfqnAtwGxXsVND6PWB3Zo9mGqam04sXeePTo4TxIbuK3mEX8Stp3QTO8mcEcdqiINq5juEECcYdYXwbuJ2Kf4vS07zNEk829StpdieadnUumbrARdE7Lyaf5nJxmpH2t8INB1wuEcTN4zGNrpkpJGNq55wph1tO802)t4Yvp0Jwi4L0)1bV9smatrScxpXZapXHNq7j0Ec9u3cchvt9BePFX6rbCNYCZTrn3yQ)YObhBo0upq4YjCBQlg4LOyuK4VqWliOXNOEz0GJ5zxp1YtAkyyfJIe)fcEbbn(effep76zaHayOXLcyrAlAkctuK3mEX8CVbEghW8SRNq5PwEkg4LOycI0wh82lXaQxgn4yE21tT8eMt(6G3EjgqrbXtnA8umWlrXeePTo4TxIbuVmAWX8SRNA5jtqK26G3EjgqrbXtON6wq4OAQFJi9lwpkG7uMBUD7CJP(lJgCS5qt9aHlNWTPUyGxIIhomfbF1lJgCmp76PyGxIQzm5KfcEj9FDWBVeM6LrdoMND9KMcgwXdhMIGVIcIND9KMcgw1mMCYcbVK(Vo4TxctrbzQBbHJQPombXKfRhfWDkZn3IJ5gt9xgn4yZHM6bcxoHBtDAkyyLXcVWSkCffKPUfeoQM6alsBrtryYuMBUn6ZnM6VmAWXMdn1TGWr1uhgyTVy9OaUt9aHlNWTPo5WKZ6nAW9SRNwq4r(1R34N5jE8CRND9KMcgwXOiXFHGxqqJprrbzQhWpa(sms8f2CZTtzU52Hp3yQ)YObhBo0upq4YjCBQlg4LOycI0wh82lXaQxgn4yE21ZacbWqJRf5wq8SRN0uWWkgfj(le8ccA8jkkiE21tO884eKhKJTcOgTjlWRyP3Zo9u4T7zNEgqiagACPycI0wh82lXakYBgVyE2PNB1wuEgbpHbieXtO8ekppob5b5yRaQrBYc8kw69StpfE7E2PNbecGHgxkMGiT1bV9smGI8MXlMNq7jEXZTAlkpH2Z98m6r5ze8ekp365OEcLN2(FcxU6HE0cbVK(Vo4TxIbykIv46jEg4jo8eApH2tnA8ekp3Q2omEgbpHYZJtqEqo2kGA0MSaVILEp70tH3UNq7zNEgqiagACPycI0wh82lXakYBgVyE2PNB1wuEgbpHbieXtO8ekp3Q2omEgbpHYZJtqEqo2kGA0MSaVILEp70tH3UNq7zNEgqiagACPycI0wh82lXakYBgVyEcTN4fp3QTO8eApH2Z98ekppob5b5yRaQrBYc8kw69StpfE7E2PNbecGHgxkMGiT1bV9smGI8MXlMND65wTfLNrWtyacr8ekpHYZJtqEqo2kGA0MSaVILEp70tH3UND6zaHayOXLIjisBDWBVedOiVz8I5j0EIx8CR2IYtO9eApHEQBbHJQPoWI0w0ueMmL5MB12CJP(lJgCS5qt9aHlNWTPUwEkg4LOycI0wh82lXaQxgn4yE21ZacbWqJRf5wq8SRN0uWWkgfj(le8ccA8jkkiE21tO884eKhKJTcOgTjlWRyP3Zo9u4T7zNEgqiagACPG5KVo4TxIbuK3mEX8Stp3QTO8mcEcdqiINq5juEECcYdYXwbuJ2Kf4vS07zNEk829StpdieadnUuWCYxh82lXakYBgVyEcTN4fp3QTO8eAp3ZZOhLNrWtO8CRNJ6juEA7)jC5Qh6rle8s6)6G3EjgGPiwHRN4zGN4WtO9eAp1OXtO8CRA7W4ze8ekppob5b5yRaQrBYc8kw69StpfE7EcTND6zaHayOXLcMt(6G3EjgqrEZ4fZZo9CR2IYZi4jmaHiEcLNq55w12HXZi4juEECcYdYXwbuJ2Kf4vS07zNEk829eAp70ZacbWqJlfmN81bV9smGI8MXlMNq7jEXZTAlkpH2tO9CppHYZJtqEqo2kGA0MSaVILEp70tH3UND6zaHayOXLcMt(6G3EjgqrEZ4fZZo9CR2IYZi4jmaHiEcLNq55XjipihBfqnAtwGxXsVND6PWB3Zo9mGqam04sbZjFDWBVedOiVz8I5j0EIx8CR2IYtO9eApHEQBbHJQPoWI0w0ueMmL5MBhM5gt9xgn4yZHM6bcxoHBtDAkyyfJIe)fcEbbn(effKPUfeoQM6aECVu8kErJaYuMBUfNFUXu)Lrdo2COPEGWLt42upGqam04ArUfep76PwEkg4LOAgtozHGxs)xh82lHPEz0GJn1TGWr1uhyrAlAkctMYCZT775gt9xgn4yZHM6bcxoHBtDXaVefpCykc(Qxgn4yE21tT8ekpB2bmHGAEIhpX51MND9mGqam04sbSiTfnfHjkYBgVyEU3apJYtO9SRNq5PwEkg4LOycI0wh82lXaQxgn4yEQrJNbecGHgxkMGiT1bV9smGI8MXlMN755wCeLNqp1TGWr1uNhomfb)Pm3ClEBUXu)Lrdo2COPEGWLt42upGqam04ArUfep76zO3iXN5jE8umWlr9qpAHGxs)xh82lHPEz0GJn1TGWr1uhyrAlAkctMYCtCe1CJP(lJgCS5qt9aHlNWTPUyGxIIhomfbF1lJgCmp76jnfmSIhomfbFffep76jnfmSIhomfbFf5nJxmp3ZZTQTEgbpJdyEgbpPPGHv8WHPi4RyIfWDQBbHJQPombXKfRhfWDkZnXX25gt9xgn4yZHM6bcxoHBt9acbWqJRf5wqM6wq4OAQdSiTfnfHjtzUjoWXCJP(lJgCS5qtDliCun1Hbw7lwpkG7upq4YjCBQtom5SEJgCp76PwEstbdRyuK4VqWliOXNOOGm1d4haFjgj(cBU52Pm3ehrFUXu)Lrdo2COPEGWLt42uxmWlrji5TvZyYj4REz0GJ5zxpHYtAkyyf5muzv4lbjVPiVz8I55EEomEQrJNq5jnfmSICgQSk8LGK3uK3mEX8CppHYtAkyyLXcVWSkCfgfXeoQ8CupdieadnUugl8cZQWvK3mEX8eAp76zaHayOXLYyHxywfUI8MXlMN755wT5j0Ec9u3cchvtDbjVTAgtob)Pm3ehdFUXu)Lrdo2COPEGWLt42uxmWlrXdhMIGV6LrdoMND9KMcgwXdhMIGVIcIND9ekpPPGHv8WHPi4RiVz8I55EEghW8mcEoCpJGN0uWWkE4Wue8vmXc46PgnEstbdRycI0W9hYjkkiEQrJNA5PyGxIQzm5KfcEj9FDWBVeM6LrdoMNqp1TGWr1uhMGyYI1Jc4oL5M4qBZnM6wq4OAQd4X9sXR4fncit9xgn4yZHMYCtCmmZnM6VmAWXMdn1TGWr1uhgyTVy9OaUt9a(bWxIrIVWMBUDQhiC5eUn1jhMCwVrd(uVHIKxXt9TtzUjoW5NBm1Fz0GJnhAQhiC5eUn1BOiF7LOW4mXQW9epEomtDliCun1Hbw7lwpkG7uVHIKxXt9TtzUjo23ZnM6nuK8kEQVDQBbHJQPombXKfRhfWDQ)YObhBo0uMYu3qFUXCZTZnM6VmAWXMdn1deUCc3M6IbEjkMGinC)HCI6Lrdo2u3cchvtDMGinC)HCYuMBIJ5gt9xgn4yZHM6wq4OAQddS2xSEua3PEGWLt42uNCyYz9gn4E21tO8Kb5aWsms8fMk0B8Ab4X9sXRyp3ZtO8uBE2PNA5PyGxIsqYBRMXKtWx9YObhZtO9uJgp1YtXaVeftqK26G3Ejgq9YObhZZUEcLNWCYxh82lXakYBgVyEIhpHYZTd3Zi4jdYbGvVXK7j0EQrJNbecGHgxkyo5RdE7Lyaf5nJxmp3ZtO8ehd3Zo9C7W9mcEYGCay1Bm5EcTNq7j0E21tO8ulpfd8sumbrARdE7Lya1lJgCmp1OXtMGiT1bV9smGcdnU8uJgpzqoaSeJeFHPc9gVwaECVu8k2ZbEgDp76jnfmSAmVWwXumrXelGRN7552H7j0t9a(bWxIrIVWMBUDkZnJ(CJP(lJgCS5qt9aHlNWTPUyGxIYyHxywfU6LrdoMND9ekpfd8sumbrARdE7Lya1lJgCmp76jtqK26G3EjgqHHgxE21ZacbWqJlftqK26G3EjgqrEZ4fZt845wT5PgnEQLNIbEjkMGiT1bV9smG6LrdoMNq7zxpHYtT8umWlrXdhMIGV6LrdoMNA04PwEstbdR4HdtrWxrbXZUEQLNbecGHgxkE4Wue8vuq8e6PUfeoQM6gl8cZQWNYCZHp3yQ)YObhBo0upq4YjCBQlg4LOa8icfhB1S4MTeK8M6Lrdo2u3cchvtDapIqXXwnlUzlbjVnL5MABUXu)Lrdo2COPEGWLt42uxlpfd8sunJjNSqWlP)RdE7LWuVmAWX8uJgpPPGHvmbrA4(d5effep1OXZMDatiOMN4zGNq552OIYZo9C4EgbpzqoaSeJeFHPc9gVwaECVu8k2tO9uJgpPPGHvnJjNSqWlP)RdE7LWuuq8uJgpzqoaSeJeFHPc9gVwaECVu8k2t84z0N6wq4OAQFJi9rekd3pL5MdZCJP(lJgCS5qt9aHlNWTPonfmSIjisd3FiNOiVz8I55EEgDpJGNXbmpJGN0uWWkMGinC)HCIIjwa3PUfeoQM6HEJxlapUxkEfpL5M48ZnM6VmAWXMdn1deUCc3M60uWWkGfPTyuK4ROG4zxpzqoaSeJeFHPc9gVwaECVu8k2Z98C4E21tO8ulpfd8sumbrARdE7Lya1lJgCmp1OXtMGiT1bV9smGcdnU8eAp76jgsuWaR9fRhfWvj8aU8kEQBbHJQPoWI0w0ueMmL5M775gt9xgn4yZHM6bcxoHBtDgKdalXiXxyQqVXRfGh3lfVI9CpphUND9ulpPPGHvgl8cZQWvuqM6wq4OAQZdhMIG)uMBI3MBm1Fz0GJnhAQhiC5eUn1zqoaSeJeFHPc9gVwaECVu8k2Z98C4E21tAkyyfpCykc(kkiE21tT8KMcgwzSWlmRcxrbzQBbHJQPombXKfRhfWDkZn3g1CJP(lJgCS5qt9aHlNWTPUyGxI6G3EjgyrdmMOEz0GJ5zxpzqoaSeJeFHPc9gVwaECVu8k2Z98C4E21tO8ulpfd8sumbrARdE7Lya1lJgCmp1OXtMGiT1bV9smGcdnU8e6PUfeoQM6h82lXalAGXKPm3C725gt9xgn4yZHM6bcxoHBtDXaVeLXcVWSkC1lJgCSPUfeoQM6alsBrFRnL5MBXXCJPUfeoQM6HEJxlapUxkEfp1Fz0GJnhAkZn3g95gt9xgn4yZHM6bcxoHBtDXaVeLXcVWSkC1lJgCSPUfeoQM6alsBrtryYuVHIKxXt9TtzU52Hp3yQ)YObhBo0u3cchvtDyG1(I1Jc4o1d4haFjgj(cBU52PEGWLt42uNCyYz9gn4t9gksEfp13oL5MB12CJPEdfjVIN6BN6wq4OAQdtqmzX6rbCN6VmAWXMdnLPm1XoSrbK5gZn3o3yQ)YObhBsp1deUCc3M62(FcxUYQWzcXalYzOYQWvVmAWXM6wq4OAQtdqimaftMYCtCm3yQ)YObhBo0upq4YjCBQFCcYdYXwbuJ2Kf4vS07zNEk829CppJEuEQrJNWCYxh82lXakkiEQrJNmbrARdE7LyaffKPUfeoQM6qqchvtzUz0NBm1TGWr1uFmVWwS(BKP(lJgCS5qtzU5WNBm1Fz0GJnhAQhiC5eUn1fd8sucsEB1mMCc(Qxgn4yE21tAkyyf5muzv4lbjVPiVz8I55EEIJPUfeoQM6csEB1mMCc(tzUP2MBm1Fz0GJnhAQhiC5eUn11YtXaVeftqK26G3Ejgq9YObhBQBbHJQPomN81bV9smWuMBomZnM6VmAWXMdn1deUCc3M6IbEjkMGiT1bV9smG6LrdoMND9ekp1YtXaVefpCykc(Qxgn4yEQrJNA5jnfmSIhomfbFffep76PwEgqiagACP4HdtrWxrbXtO9SRNq5PwEkg4LOmw4fMvHREz0GJ5PgnEQLNbecGHgxkJfEHzv4kkiE21tT8KMcgwzSWlmRcxrbXtON6wq4OAQZeePTo4TxIbMYCtC(5gtDliCun1PyFXL3yt9xgn4yZHMYCZ99CJP(lJgCS5qt9aHlNWTPUwEkg4LOmw4fMvHREz0GJ5PgnEstbdRmw4fMvHROG4PgnEgqiagACPmw4fMvHRiVz8I5jE8uBrn1TGWr1uNgGqylykc(tzUjEBUXu)Lrdo2COPEGWLt42uxlpfd8sugl8cZQWvVmAWX8uJgpPPGHvgl8cZQWvuqM6wq4OAQtFc7eC5v8uMBUnQ5gt9xgn4yZHM6bcxoHBtDT8umWlrzSWlmRcx9YObhZtnA8KMcgwzSWlmRcxrbXtnA8mGqam04szSWlmRcxrEZ4fZt84P2IAQBbHJQPomNCAacHnL5MB3o3yQ)YObhBo0upq4YjCBQRLNIbEjkJfEHzv4Qxgn4yEQrJN0uWWkJfEHzv4kkiEQrJNbecGHgxkJfEHzv4kYBgVyEIhp1wutDliCun1TkCMqmWkyaWuMBUfhZnM6VmAWXMdn1deUCc3M6mbrARdE7Lyaffep76jnfmSkyaWcWJ7LIxXkYBgVyEINbEUVN6wq4OAQF8)cbVK(VycI0MYCZTrFUXu3cchvt92LJit9xgn4yZHMYCZTdFUXu)Lrdo2COPEGWLt42u3ccpYVE9g)mpXJN4WZUEcLNmihawIrIVWuHEJxlapUxkEf7jE8ehEQrJNmihawIrIVWualsBrFR5jE8ehEc9u3cchvtDcvTSGWr1cWzYuhWzYQS2N6g6tzU5wTn3yQ)YObhBo0u3cchvtDcvTSGWr1cWzYuhWzYQS2N6mEfd(sms8LPmLPoeYdOgTjZnMBUDUXu)Lrdo2COPm3ehZnM6VmAWXMdnL5MrFUXu)Lrdo2COPm3C4ZnM6VmAWXMdnL5MABUXu3cchvtDbjVTAgtob)P(lJgCS5qtzU5Wm3yQ)YObhBo0upq4YjCBQRLNIbEjkieEZaRdE7LyaotuVmAWXM6wq4OAQFJi9RdE7LyGPm3eNFUXu)Lrdo2COPEGWLt42uxmWlrXeePH7pKtuVmAWX8SRNq5jX4yRh5lrzyymvarvIN75z09uJgpjghB9iFjkddJP4LN4XtTfLNqp1TGWr1uNjisd3FiNmL5M775gt9xgn4yZHM6bcxoHBtDT8umWlrXeePTo4TxIbuVmAWXM6wq4OAQdZjFDWBVedmL5M4T5gt9xgn4yZHM6bcxoHBtDXaVeftqK26G3Ejgq9YObhBQBbHJQPotqK26G3EjgykZn3g1CJPUfeoQM6qqchvt9xgn4yZHMYCZTBNBm1Fz0GJnhAQhiC5eUn1fd8suh82lXalAGXe1lJgCSPUfeoQM6h82lXalAGXKPm3CloMBm1Fz0GJnhAQhiC5eUn11YtXaVe1bV9smWIgymr9YObhZZUEYGCayjgj(ctf6nETa84EP4vSN75z0N6wq4OAQdSiTfnfHjtzU52Op3yQ)YObhBo0upq4YjCBQZGCayjgj(ctf6nETa84EP4vSN4XtCm1TGWr1up0B8Ab4X9sXR4PmLPm1nkPhrM668gfWeoQIOjgSmLPmNa]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_intellect",

        package = "Elemental",
    } )
end
