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


    spec:RegisterPack( "Elemental", 20190208.1030, [[d8emIbqiHWJes5sqfXMuu(eur1OaPofizvKO6vkQAwIsDlHKDrQFjenmrjhtPyzqv8mrrMMOOUgjITPOcFtPQsJJefDoLQQwNIkL3POsfnpOc3trSpOkDqsuQfQi5HKOetuiv6IKiTrLQk(OIkvnsfvQWjHksTsLsVeQiPzsIc3urLStLQ8tOIedvrfTuHuLNsstvrQRkKQ6RKOKgRIkvAVk8xLmyPomLfJkpwWKHYLvTzq9zHA0IQtJ0RHknBGBlYUL8BidhehhQOSCephLPtCDu12ff(UsLXRuvopuvRxivmFsy)u9yZy6HkMjFShEYAZ(NfEYszQ3KvMuM4zZqvWhYhQqSaUw8hQLL(qvPGNEjgyOcXWhGmSX0dvgINe(qnxeiS5wKrgtLCEoDaLIKrt8atOOkqmyjsgnfIKdG4IKd2Ic7zejeccMcolY5K8ONrXyroNrVLAULSAPuWtVedOz0uyOYXtbcoDn4gQyM8XE4jRn7Fw4jlLPEtw4jt4jZdvgKhg7HN5apd1Ckg2Rb3qf7SWqnAERuWtVed4TAULSY3gnVZfbcBUfzKXujNNthqPiz0epWekQcedwIKrtHi5aiUi5GTOWEgrcHGGPGZICojp6zumwKZz0BPMBjRwkf80lXaAgnf8TrZ79Z5i8gbFVvMz7nEYAZ(7DuEVjR5ww7xVv2ZLV13gnVvwYTk(S5MVnAEhL3rF29EU76GNEjgqZdXBIj5N4TKBL3H8hWLwXEhqiagAxX8wqEZ(9Mc79bp9smaZBJCVTGqZ4AFB08okVJUuMXboM3k1isU3kf80lXaE)si0Z0(2O5DuEh9EcLX9wzZcVWSkCVfA6roLYW7q(d4Q9TrZ7O8wzJH5TsX)EJG9wYV3QcIK8osVNRlhr0dvieemf8HA08wPGNEjgWB1ClzLVnAENlce2ClYiJPsopNoGsrYOjEGjuufigSejJMcrYbqCrYbBrH9mIecbbtbNf5CsE0ZOySiNZO3sn3swTuk4PxIb0mAk4BJM37NZr4nc(ERmZ2B8K1M937O8EtwZTS2VERSNlFRVnAERSKBv8zZnFB08okVJ(S79C31bp9smGMhI3etYpXBj3kVd5pGlTI9oGqam0UI5TG8M97nf27dE6LyaM3g5EBbHMX1(2O5DuEhDPmJdCmVvQrKCVvk4PxIb8(LqONP9TrZ7O8o69ekJ7TYMfEHzv4El00JCkLH3H8hWv7BJM3r5TYgdZBLI)9gb7TKFVvfej5DKEpxxoIO9T(2O5Ts33d8YX8M7WiY9oGsCM4n3JPft7TYoeoeH5DHQOYnscMh4TfekQyEJka(AFRfekQyAiKhqjotMadmgU(wliuuX0qipGsCMm)KiHrimFRfekQyAiKhqjotMFsKgFC6Lycfv(wFB08wTmiSCK4nXOyEZXddFmVzIjmV5omICVdOeNjEZ9yAX82kmVHqEuqqIqRyVPmVXq11(wliuuX0qipGsCMm)KizLbHLJKftmH5BTGqrftdH8akXzY8tIuqYtRKXKtW33AbHIkMgc5buIZK5Ne5nIKVo4PxIbYMcpjcXaVenecnzG1bp9smaLj6xgh4y(wFB08o6ZU3QcIKW9hYjEdH8akXzI38f4mM3mu6EByymV3rbaVzqSDL3meQ0(wliuuX0qipGsCMm)KizcIKW9hYjztHNig4LOzcIKW9hYj6xgh4yZGMyuS1Z4LOnmmMoG4lbhzsHcIrXwpJxI2WWyAAHxLKfu(wFRfekQyAiKhqjotMFsKWuYxh80lXaztHNeHyGxIMjisADWtVedOFzCGJ5BTGqrftdH8akXzY8tIKjisADWtVedKnfEIyGxIMjisADWtVedOFzCGJ5BTGqrftdH8akXzY8tIecsOOY3AbHIkMgc5buIZK5Ne5bp9smWIdymjBk8eXaVe9bp9smWIdymr)Y4ahBgdYbGLyK4lmDi3O1cqJZLIwX4it(wliuuX0qipGsCMm)Kibwg2IJNWKSPWtIqmWlrFWtVedS4agt0VmoWXMXGCayjgj(cthYnATa04CPOvmoYKV1ccfvmneYdOeNjZpjYqUrRfGgNlfTIZMcpHb5aWsms8fMoKB0AbOX5srRy8IhFRVnAER099aVCmVFgNGV3cnDVL87TfeeXBkZBldJcmoW1(2O5TYIXeVNcGqyaEM4DYkEdaW3BkS3s(9wzhDoHk37Pjgv8wzxHZeIb8o6DgQSkCVPmVHqo7LO9TwqOOInHdGqyaEMKnfEIfDoHkxBv4mHyGf5muzv46xgh4y(wFB08gNUIkGsCM4neKqrL3uM3qih(Kxc1aa89gqlCpM3cYB8r8eVvk4PxIbY2B(cCgZ7akXzI37OaG3VW8MLJicaFFRfekQyZpjsiiHIQSPWt((G8GCSvaL4mzbEfl5rj00XrMYsHcyk5RdE6LyanpefkycIKwh80lXaAEi(wFB08gNUKti8qeVrWEhmMW0(wliuuXMFsK7Of2ILFJ4B9TwqOOIn)KifK80kzm5e8ZMcprmWlrli5PvYyYj4RFzCGJnJJhgwtodvwf(sqYtAYtgTy4ap(wliuuXMFsKWuYxh80lXaztHNeHyGxIMjisADWtVedOFzCGJ5BTGqrfB(jrYeejTo4PxIbYMcprmWlrZeejTo4PxIb0VmoWXMbDeIbEjAA4W8e81VmoWXuOicoEyynnCyEc(AEiZIiGqam0UstdhMNGVMhcu(2O5TfekQyZpjYBejFDWtVedKnfEseIbEjAieAYaRdE6Lyakt0VmoWXuOqmWlrdHqtgyDWtVedqzI(LXbo2mOHPKVo4PxIb0yOD1Sied8s0mbrsRdE6Lya9lJdCmfkycIKwh80lXaAm0UAMyGxIMjisADWtVedOFzCGJbLV1ccfvS5Nejp7lQ8eZ3AbHIk28tIKdGqylyEc(ztHNeHyGxI2yHxywfU(LXboMcfC8WWAJfEHzv4AEikueqiagAxPnw4fMvHRjpz0IHxLKLV1ccfvS5Nej3jStWLwXztHNeHyGxI2yHxywfU(LXboMcfC8WWAJfEHzv4AEi(wliuuXMFsKWuY5aiew2u4jrig4LOnw4fMvHRFzCGJPqbhpmS2yHxywfUMhIcfbecGH2vAJfEHzv4AYtgTy4vjz5BTGqrfB(jrAv4mHyGvWaGSPWtIqmWlrBSWlmRcx)Y4ahtHcoEyyTXcVWSkCnpefkcieadTR0gl8cZQW1KNmAXWRsYY3AbHIk28tI84)fcEj5FXeejLnfEctqK06GNEjgqZdzghpmSoyaWcqJZLIwXAYtgTy4DIY03AbHIk28tImD5iIV1ccfvS5NejHVwwqOOAbOmj7YsFIHE2u4jwqOz81RNONHx8mdAgKdalXiXxy6qUrRfGgNlfTIXlEuOGb5aWsms8fMgyzylUBj8IhO8TwqOOIn)Kij81YccfvlaLjzxw6ty0kg8LyK4l(wFB08EU4bc1BXiXx82ccfvEdHqreQGV3akt8TwqOOIPn0NWeejH7pKtYMcprmWlrZeejH7pKt0VmoWX8T(2O5TkeYnmV3palDVvZrbC9MwEJJjENzVfJeFXByACUWY2BoEX7cjEJXtOvS3Qk1BEicn9S5lWzmVXhXJZj3ByACUqRyVZK3IrIVW82kmVZTmU3GZyEl5w59Mm7TYkTW8EUNNjEZelGlt7BTGqrftBOp)KiHbw6lwokGB2b8dGVeJeFHnzt2u4jKdtol34aFg0mihawIrIVW0HCJwlanoxkAfJdOvsurig4LOfK80kzm5e81VmoWXGsHIied8s0mbrsRdE6Lya9lJdCSzqdtjFDWtVedOjpz0IHxO3KzLZGCayLBm5qPqraHayODLgMs(6GNEjgqtEYOfdhqJNmh1MmRCgKdaRCJjhkOGAg0rig4LOzcIKwh80lXa6xgh4ykuWeejTo4PxIb0yODLcfmihawIrIVW0HCJwlanoxkAfpjtZ44HH17Of2kMNjAMybCXXMmdLV1ccfvmTH(8tI0yHxywfE2u4jIbEjAJfEHzv46xgh4yZGwmWlrZeejTo4PxIb0VmoWXMXeejTo4PxIb0yOD1SacbWq7kntqK06GNEjgqtEYOfdVBuIcfrig4LOzcIKwh80lXa6xgh4yqnd6ied8s00WH5j4RFzCGJPqreC8WWAA4W8e818qMfraHayODLMgompbFnpeO8TwqOOIPn0NFsKakoJNITswCYwcsEkBk8eXaVenGIZ4PyRKfNSLGKN0VmoWX8T(2O590e89wqEhBP7TsnIKJZ4nCV37OsU3ZLXKt8gb7TKFVvk4PxcZBoEyyV3L)YByACUqRyVZK3IrIVW0EhDrfox8gLXjbdI3ZLDatiOue(wliuuX0g6ZpjYBejhNXB4(SPWtIqmWlrNmMCYcbVK8Vo4Pxct)Y4ahtHcoEyyntqKeU)qorZdrHIKDatiOeENa9MSYkQmRCgKdalXiXxy6qUrRfGgNlfTIHsHcoEyyDYyYjle8sY)6GNEjmnpefkyqoaSeJeFHPd5gTwaACUu0kgVzY36BJM3ZLH79MXtU34J49gdv4CXBaIDVnVvfejH7pKt0(wliuuX0g6ZpjYqUrRfGgNlfTIZMcpHJhgwZeejH7pKt0KNmAXWrMuECat5C8WWAMGijC)HCIMjwaxFRVnAEJtPa47DWyI3kdldZ7P4jmXBu5TKt(9wms8fM3uyVPI3uM3w5nTyIvI3wH5TQGijVvk4PxIb8MY8EpCkt7TfeAgx7BTGqrftBOp)Kibwg2IJNWKSPWt44HH1aldBX4jXxZdzgdYbGLyK4lmDi3O1cqJZLIwX4iZZGocXaVentqK06GNEjgq)Y4ahtHcMGiP1bp9smGgdTRGAggs0Wal9flhfWvl0aU0k23AbHIkM2qF(jrsdhMNGF2u4jmihawIrIVW0HCJwlanoxkAfJJmplcoEyyTXcVWSkCnpeFRfekQyAd95NejmbXKflhfWnBk8egKdalXiXxy6qUrRfGgNlfTIXrMNXXddRPHdZtWxZdzweC8WWAJfEHzv4AEi(wFB08o6ZU3kf80lXaEpfWyI3wSrlM4npeVfK3zYBXiXxyEBmVbOk2BJ5TQGijVvk4PxIb8MY8UqI3wqOzCTV1ccfvmTH(8tI8GNEjgyXbmMKnfEIyGxI(GNEjgyXbmMOFzCGJnJb5aWsms8fMoKB0AbOX5srRyCK5zqhHyGxIMjisADWtVedOFzCGJPqbtqK06GNEjgqJH2vq5BTGqrftBOp)Kibwg2I7wkBk8eXaVeTXcVWSkC9lJdCmFRfekQyAd95Nezi3O1cqJZLIwX(wliuuX0g6ZpjsGLHT44jmj7ekdAfpzt2u4jIbEjAJfEHzv46xgh4y(wliuuX0g6ZpjsyGL(ILJc4MDcLbTINSj7a(bWxIrIVWMSjBk8eYHjNLBCG7BTGqrftBOp)KiHjiMSy5OaUzNqzqR4jB8T(2O5TkTIb37Pns8fVv2bHIkVNtcfrOc(ERmOmX3gnVvAX4j379JQ3uM3wqOzCV5lWzmVXhX7DULX9EtM9gr8oHi3BMybCzEJG9wzLwyEp3ZZeVHjOK3QcIK8wPGNEjgq7n0kfl(Ehm2NBEZdjGs0k2BLnl4nhV4TfeAg3BvLo3P3yOcNlEdLV1ccfvmnJwXGVeJeFzcmWsFXYrbCZMcpb6ieAaxAfRqHyGxIMjisADWtVedOFzCGJnlGqam0UsZeejTo4PxIb0KNmAXWbEuECatHcmKOHbw6lwokGRM8KrlgoMehWuOqmWlrBSWlmRcx)Y4ahBggs0Wal9flhfWvtEYOfdhqhqiagAxPnw4fMvHRjpz0InphpmS2yHxywfUgJNycfvqnlGqam0UsBSWlmRcxtEYOfdhzEg0rig4LOzcIKwh80lXa6xgh4ykuig4LOzcIKwh80lXa6xgh4yZycIKwh80lXaAm0UckOMXXddR3rlSvmpt0mXc4IJnzEweC8WWAgpj(le8ccA3jAEi(wFB08o6ZU3kBw4fMvH7TblN4n(iECEg3BgKxI3ga4TYWYW8EkEct8oKBK4Z82kmVrfaFVPWExNk5N4TQGijVvk4PxIb8UqeVXPdhMNGV3g5Eh4jKxcaFVTGqZ4AFRfekQyAgTIbFjgj(Y8tI0yHxywfE2u4jIbEjAJfEHzv46xgh4yZcieadTR0aldBXXtyIM8KrlgEZAg0rig4LOzcIKwh80lXa6xgh4ykuWeejTo4PxIb08qGAg0rig4LOPHdZtWx)Y4ahtHIi44HH10WH5j4R5HmlIacbWq7knnCyEc(AEiq5B9TrZ7OlQW5I38S7Tsbp9smG3tbmM4nf2B8r8Ehq8amVdgt828EUmMCI3iyVL87Tsbp9syE)ee0UtoM3k1isU3Q5OaUEtlMCdt7D0fv4CX7GXeVvk4PxIb8EkGXeVX4j0k2BvbrsERuWtVed4nFboJ5n(iEVZTmU3zAFEVNj8ed49ChgjHk89MwEVlNgY9oyS7n(iEVzccI38mAf7Tsbp9smG3tbmM4nQc3B8r8EtUfY9EtM9MjwaxM3iyVvwPfM3Z98mr7BTGqrftZOvm4lXiXxMFsKh80lXaloGXKSPWted8s0h80lXaloGXe9lJdCSzqlg4LOtgtozHGxs(xh80lHPFzCGJnJJhgwNmMCYcbVK8Vo4PxctZdzwYoGjeuchZrwkueHyGxIozm5KfcEj5FDWtVeM(LXboguZGocOzcIKwh80lXaAEiZed8s0mbrsRdE6Lya9lJdCmOuOWIoNqLRlt4jgyLBKeQWxtSc3jzAghpmSEhTWwX8mrZelGlo2KzO8T(2O5no1FiERIt1ByeXBGrIV3iI3meQ82WW8ENLXzAVJ(f4mM34J49o3Y4ERYtIV3iyVNt0UtY2BA59UCAi37GXU34J49ENvI3cYBmeph4EZXdd7TYGgNlfTI9Ekeq8MdFVHGqaAf79CzhWeck5n3HrKNBfM2BLUplbbCVzhNX)k85M3BYkR5snBVvQA2ERItnBVvgtLT3kJmMkBVvQA2ERmMY3AbHIkMMrRyWxIrIVm)KizcIKW9hYjztHNig4LOzcIKW9hYj6xgh4yZGMyuS1Z4LOnmmMoG4lbhzsHcIrXwpJxI2WWyAAHxLKfuZGocXaVenJNe)fcEbbT7e9lJdCmfk44HH1mEs8xi4fe0Ut08quOizhWeckH3jzoZq5B9TwqOOIPz0kg8LyK4lZpjsafNXtXwjlozlbjpLnfEIyGxIgqXz8uSvYIt2sqYt6xgh4yZGMyuS1Z4LOnmmMoG4lbhzsHcIrXwpJxI2WWyAAHxLKfu(wFB08wzbL4O19wvqKeU)qoX7Duj375YyYjEJG9wYV3kf80lH5nI4Tkpj(EJG9Eor7or7BTGqrftZOvm4lXiXxMFsKaACUu0kEXHas2u4jC8WWAMGijC)HCIMhYmgKdalXiXxy6qUrRfGgNlfTIXbEMbnhpmSozm5KfcEj5FDWtVeMMhYSied8s0mEs8xi4fe0Ut0VmoWXuOGJhgwZ4jXFHGxqq7orZdbkFRVnAEpD(j37enox8oGs3BR8MhcMj3ByeXBjNY8gqR79oQK7ndLU3QO50BakMg0(wliuuX0mAfd(sms8L5Ne5nIKJZ4nCF2u4jwqOz81RNONH3nZyqoaSeJeFHPd5gTwaACUu0kgVBMbDeIbEjAgpj(le8ccA3j6xgh4ykuebgs0Wal9flhfWvtom5SCJdCfkycIKwh80lXaAEiqnd6ied8s0jJjNSqWlj)RdE6LW0VmoWXuOGJhgwNmMCYcbVK8Vo4PxctZdrHIKDatiOeENS)4bkFRVnAEpfcFTwVl3eVnVdOcJkuuP9wzLk5EpxgtoXBeS3s(9wPGNEjmVHGqaVNl7aMqqjV5H4TG8wz69CzhWeck5n3bODEl537GbXBb59lgp5EtfCoZBE2X8EhvY9wPgrY9wnhfWv7TYkvYr8I3ZLXKt8gb7TKFVvk4PxclBV5z3BLAej3B1CuaxVpvYpXBkS3QcIKW9hYjEtzEZdjBVNl7aMqqjVPmV3KL3ZLDatiOK3ChG25TKFVdgeVreVbNXY2BeX7tL8t8wvqKK3kf80lXaEtzfox8wmWl5yEJiEtfCoZ7cjEBbHMX92kmVXhXt8gymXBvbrsERuWtVed4nc2Bj)EdtJZfV3rbaVZTmU3OcGV3M3qmIqnG3y8etOOs7BTGqrftZOvm4lXiXxMFsK3is(ILJc4MnfEseC8WWAgpj(le8ccA3jAEiZed8s0jJjNSqWlj)RdE6LW0VmoWXMbnhpmSozm5KfcEj5FDWtVeMMhIcfj7aMqqj8oz)XZ8zklLlg4LOdgaSK8VKC(c7e9lJdCmfk44HH1mbrs4(d5enpKzwqOz81RNONHd8aLcfrig4LOtgtozHGxs(xh80lHPFzCGJndAoEyyntqKeU)qorZdrHIKDatiOeENS)znFMYs5IbEj6Gbalj)ljNVWor)Y4ahtHIiGMjisADWtVedO5HmtmWlrZeejTo4PxIb0VmoWXGA23hKhKJTcOeNjlWRyjpkHMEubecGH2vAMGiP1bp9smGM8KrlwuBuswkhgGqeOH(7dYdYXwbuIZKf4vSKhLqtpQacbWq7kntqK06GNEjgqtEYOfdkCYgLKfu4DsMYs5qVzEOTOZju56hYrle8sY)6GNEjgGPjwHlENGhOGckFRVnAEh9z3BLAej3B1CuaxVPWERYtIV3iyVNt0Ut8MY8wmWl5yz7nhV4DDQKFI3uX7cr828o6oNQERuWtVed4nL5TfeAg3Bt8wYV3ju6LKT3wH5TYWYW8EkEct8MY8MCddFVreV3rbaV5U37OsoT8wYV313N49CVYs0v7BTGqrftZOvm4lXiXxMFsK3is(ILJc4MnfEIyGxIMXtI)cbVGG2DI(LXbo2Si44HH1mEs8xi4fe0Ut08qMfqiagAxPbwg2IJNWen5jJwmCmjoGnd6ied8s0mbrsRdE6Lya9lJdCSzranmL81bp9smGMhcukuig4LOzcIKwh80lXa6xgh4yZIaAMGiP1bp9smGMhcuq5B9TrZBLfJjERmOX5srRyVNcbeM3y8eAf7TQGijVvk4PxIb8gJNycfvAFRfekQyAgTIbFjgj(Y8tIeqJZLIwXloeqYMcpHjisADWtVedO5HmtmWlrZeejTo4PxIb0VmoWX8T(2O5D0NDV3peet8wnhfW17Duj3BC6WH5j47TvyEpxgtoXBeS3s(9wPGNEjmTV1ccfvmnJwXGVeJeFz(jrctqmzXYrbCZMcprmWlrtdhMNGV(LXbo2mXaVeDYyYjle8sY)6GNEjm9lJdCSzC8WWAA4W8e818qMXXddRtgtozHGxs(xh80lHP5H4B9TwqOOIPz0kg8LyK4lZpjsGLHT44jmjBk8eoEyyTXcVWSkCnpeFRVnAEh9fkGgDU3Q8K47nc275eT7eVfK3miKByEVFaw6ERMJc46nf27epqOqa37xprpZBJCVHqo7LO9TwqOOIPz0kg8LyK4lZpjsyGL(ILJc4MDa)a4lXiXxyt2KnfEc5WKZYnoWNzbHMXxVEIEgE3mJJhgwZ4jXFHGxqq7orZdX36BJM3rF29wzyzyEpfpHjEVJk5ERYtIV3iyVNt0Ut8Mc7TKFVbgt8gcsEjud4npZIV3iyVnVJUZPQ3kf80lXaENBScNlEBEdZdaEJXtmHIkVXPe98Mc7n(iEVdiEaM3Xx82kKKFI38ml(EJG9wYV3r35u1BLcE6LyaVPWEl53BYtgTOvS3W04CX7DgZ7nZboXBaQIpr7BTGqrftZOvm4lXiXxMFsKaldBXXtys2u4jIbEjAMGiP1bp9smG(LXbo2SacbWq7Qf5wqMXXddRz8K4VqWliODNO5Hmd6VpipihBfqjotwGxXsEucn9OcieadTR0mbrsRdE6Lyan5jJwSO2OKSuomaHiqd93hKhKJTcOeNjlWRyjpkHMEubecGH2vAMGiP1bp9smGM8Krlgu4KnkjlOWrMYs5qVzEOTOZju56hYrle8sY)6GNEjgGPjwHlENGhOGsHcO3O3mhkh6VpipihBfqjotwGxXsEucnDOIkGqam0UsZeejTo4PxIb0KNmAXIAJsYs5WaeIan0B0BMdLd93hKhKJTcOeNjlWRyjpkHMourfqiagAxPzcIKwh80lXaAYtgTyqHt2OKSGckCa93hKhKJTcOeNjlWRyjpkHMEubecGH2vAMGiP1bp9smGM8KrlwuBuswkhgGqeOH(7dYdYXwbuIZKf4vSKhLqtpQacbWq7kntqK06GNEjgqtEYOfdkCYgLKfuqbLV13gnVJ(S7TYWYW8EkEct8EhvY9wLNeFVrWEpNODN4nf2Bj)EdmM4neK8sOgWBEMfFVrWEBEhDNtvVvk4PxIb8o3yfox828gMha8gJNycfvEJtj65nf2B8r8Ehq8amVJV4Tvij)eV5zw89gb7TKFVJUZPQ3kf80lXaEtH9wYV3KNmArRyVHPX5I37mM3BMdCI3aufFI23AbHIkMMrRyWxIrIVm)Kibwg2IJNWKSPWtIqmWlrZeejTo4PxIb0VmoWXMfqiagAxTi3cYmoEyynJNe)fcEbbT7enpKzq)9b5b5yRakXzYc8kwYJsOPhvaHayODLgMs(6GNEjgqtEYOflQnkjlLddqic0q)9b5b5yRakXzYc8kwYJsOPhvaHayODLgMs(6GNEjgqtEYOfdkCYgLKfu4itzPCO3mp0w05eQC9d5OfcEj5FDWtVedW0eRWfVtWduqPqb0B0BMdLd93hKhKJTcOeNjlWRyjpkHMourfqiagAxPHPKVo4PxIb0KNmAXIAJsYs5WaeIan0B0BMdLd93hKhKJTcOeNjlWRyjpkHMourfqiagAxPHPKVo4PxIb0KNmAXGcNSrjzbfu4a6VpipihBfqjotwGxXsEucn9OcieadTR0WuYxh80lXaAYtgTyrTrjzPCyacrGg6VpipihBfqjotwGxXsEucn9OcieadTR0WuYxh80lXaAYtgTyqHt2OKSGckO8TwqOOIPz0kg8LyK4lZpjsanoxkAfV4qajBk8eoEyynJNe)fcEbbT7enpeFRfekQyAgTIbFjgj(Y8tIeyzyloEctYMcpjGqam0UArUfeFRVnAEhDrfox82cbk2lXaa89MNDVv5jX3BeS3ZjA3jEVJk5EVFaw6ERMJc46ngpHwXEZOvm4Elgj(I23AbHIkMMrRyWxIrIVm)KiHbw6lwokGB2b8dGVeJeFHnzt2u4jKdtol34aFweC8WWAgpj(le8ccA3jAEi(wliuuX0mAfd(sms8L5NePGKNwjJjNGF2u4jIbEjAbjpTsgtobF9lJdCSzqZXddRjNHkRcFji5jn5jJwmCmhkuanhpmSMCgQSk8LGKN0KNmAXWb0C8WWAJfEHzv4AmEIjuunFaHayODL2yHxywfUM8KrlguZcieadTR0gl8cZQW1KNmAXWXgLafu(wFB08wfqJZfa(EhBP7noD4W8e89MJhg2Bb5DocYH5ba89MJhg2BgkDV3rLCVNlJjN4nc2Bj)ERuWtVeM23AbHIkMMrRyWxIrIVm)KiHjiMSy5OaUztHNig4LOPHdZtWx)Y4ahBghpmSMgompbFnpKzqZXddRPHdZtWxtEYOfdhXbmLNzLZXddRPHdZtWxZelGRcfC8WWAMGijC)HCIMhIcfrig4LOtgtozHGxs(xh80lHPFzCGJbLV1ccfvmnJwXGVeJeFz(jrsdhMNGF2u4jIbEjAA4W8e81VmoWX8TwqOOIPz0kg8LyK4lZpjsanoxkAfV4qaX3AbHIkMMrRyWxIrIVm)KiHbw6lwokGB2jug0kEYMSd4haFjgj(cBYMSPWtihMCwUXbUV1ccfvmnJwXGVeJeFz(jrcdS0xSCua3StOmOv8KnztHNKqz80lrJrzIvHJ35W36BJM37hcIjERMJc46nL5nIN4DcLXtVeVHPaWjAFRfekQyAgTIbFjgj(Y8tIeMGyYILJc4MDcLbTINSzOMXjmkQg7HNS2S)zHNS2OXZMS2Vd1DgPOvmBOItNGGiYX8oZEBbHIkVbuMW0(2HkGYe2y6HkJwXGVeJeFzm9yVnJPhQVmoWXgtnudeQCc1gQq7DeEl0aU0k2Bfk8wmWlrZeejTo4PxIb0VmoWX8EM3becGH2vAMGiP1bp9smGM8KrlM34WB84TY9ooG5TcfEJHenmWsFXYrbC1KNmAX8ght8ooG5TcfElg4LOnw4fMvHRFzCGJ59mVXqIggyPVy5OaUAYtgTyEJdVH27acbWq7kTXcVWSkCn5jJwmVN3BoEyyTXcVWSkCngpXekQ8gkVN5DaHayODL2yHxywfUM8KrlM34W7m79mVH27i8wmWlrZeejTo4PxIb0VmoWX8wHcVfd8s0mbrsRdE6Lya9lJdCmVN5ntqK06GNEjgqJH2vEdL3q59mV54HH17Of2kMNjAMybC9ghEVjZEpZ7i8MJhgwZ4jXFHGxqq7orZdzOAbHIQHkmWsFXYrbChYyp8mMEO(Y4ahBm1qnqOYjuBOkg4LOnw4fMvHRFzCGJ59mVdieadTR0aldBXXtyIM8KrlM3417S8EM3q7DeElg4LOzcIKwh80lXa6xgh4yERqH3mbrsRdE6LyanpeVHY7zEdT3r4TyGxIMgompbF9lJdCmVvOW7i8MJhgwtdhMNGVMhI3Z8ocVdieadTR00WH5j4R5H4nudvliuununw4fMvHpKXEzAm9q9LXbo2yQHAGqLtO2qvmWlrFWtVedS4agt0VmoWX8EM3q7TyGxIozm5KfcEj5FDWtVeM(LXboM3Z8MJhgwNmMCYcbVK8Vo4PxctZdX7zENSdycbL8ghEphz5TcfEhH3IbEj6KXKtwi4LK)1bp9sy6xgh4yEdL3Z8gAVJWBO9MjisADWtVedO5H49mVfd8s0mbrsRdE6Lya9lJdCmVHYBfk82IoNqLRlt4jgyLBKeQWxtScxVN4DM8EM3C8WW6D0cBfZZentSaUEJdV3KzVHAOAbHIQH6bp9smWIdymziJ9Y8y6H6lJdCSXud1aHkNqTHQyGxIMjisc3FiNOFzCGJ59mVH2BIrXwpJxI2WWy6aIVeVXH3zYBfk8MyuS1Z4LOnmmMMwEJxVvswEdL3Z8gAVJWBXaVenJNe)fcEbbT7e9lJdCmVvOWBoEyynJNe)fcEbbT7enpeVvOW7KDatiOK34DI3zoZEd1q1ccfvdvMGijC)HCYqg7PKX0d1xgh4yJPgQbcvoHAdvXaVenGIZ4PyRKfNSLGKN0VmoWX8EM3q7nXOyRNXlrByymDaXxI34W7m5TcfEtmk26z8s0gggttlVXR3kjlVHAOAbHIQHkGIZ4PyRKfNSLGKNgYyV5ym9q9LXbo2yQHAGqLtO2qLJhgwZeejH7pKt08q8EM3mihawIrIVW0HCJwlanoxkAf7no8gpEpZBO9MJhgwNmMCYcbVK8Vo4PxctZdX7zEhH3IbEjAgpj(le8ccA3j6xgh4yERqH3C8WWAgpj(le8ccA3jAEiEd1q1ccfvdvanoxkAfV4qaziJ92VJPhQVmoWXgtnudeQCc1gQwqOz81RNON5nE9EJ3Z8Mb5aWsms8fMoKB0AbOX5srRyVXR3B8EM3q7DeElg4LOz8K4VqWliODNOFzCGJ5TcfEhH3yirddS0xSCuaxn5WKZYnoW9wHcVzcIKwh80lXaAEiEdL3Z8gAVJWBXaVeDYyYjle8sY)6GNEjm9lJdCmVvOWBoEyyDYyYjle8sY)6GNEjmnpeVvOW7KDatiOK34DI37pE8gQHQfekQgQ3isooJ3W9dzSNYCm9q9LXbo2yQHAGqLtO2qncV54HH1mEs8xi4fe0Ut08q8EM3IbEj6KXKtwi4LK)1bp9sy6xgh4yEpZBO9MJhgwNmMCYcbVK8Vo4PxctZdXBfk8ozhWeck5nEN49(JhVN37mLL3k3BXaVeDWaGLK)LKZxyNOFzCGJ5TcfEZXddRzcIKW9hYjAEiEpZBli0m(61t0Z8ghEJhVHYBfk8ocVfd8s0jJjNSqWlj)RdE6LW0VmoWX8EM3q7nhpmSMjisc3FiNO5H4TcfENSdycbL8gVt8E)ZY759otz5TY9wmWlrhmayj5Fj58f2j6xgh4yERqH3r4n0EZeejTo4PxIb08q8EM3IbEjAMGiP1bp9smG(LXboM3q59mV)(G8GCSvaL4mzbEfl5EhL3cnDVJY7acbWq7kntqK06GNEjgqtEYOfZ7O8EJsYYBL7nmaHiEdT3q793hKhKJTcOeNjlWRyj37O8wOP7DuEhqiagAxPzcIKwh80lXaAYtgTyEdL34eV3OKS8gkVX7eVZuwERCVH27nEpV3q7TfDoHkx)qoAHGxs(xh80lXamnXkC9gVt8gpEdL3q5nudvliuunuVrK8flhfWDiJ92)X0d1xgh4yJPgQbcvoHAdvXaVenJNe)fcEbbT7e9lJdCmVN5DeEZXddRz8K4VqWliODNO5H49mVdieadTR0aldBXXtyIM8KrlM34yI3XbmVN5n0EhH3IbEjAMGiP1bp9smG(LXboM3Z8ocVH2Byk5RdE6LyanpeVHYBfk8wmWlrZeejTo4PxIb0VmoWX8EM3r4n0EZeejTo4PxIb08q8gkVHAOAbHIQH6nIKVy5OaUdzS3MSgtpuFzCGJnMAOgiu5eQnuzcIKwh80lXaAEiEpZBXaVentqK06GNEjgq)Y4ahBOAbHIQHkGgNlfTIxCiGmKXEB2mMEO(Y4ahBm1qnqOYjuBOkg4LOPHdZtWx)Y4ahZ7zElg4LOtgtozHGxs(xh80lHPFzCGJ59mV54HH10WH5j4R5H49mV54HH1jJjNSqWlj)RdE6LW08qgQwqOOAOctqmzXYrbChYyVn4zm9q9LXbo2yQHAGqLtO2qLJhgwBSWlmRcxZdzOAbHIQHkWYWwC8eMmKXEBY0y6H6lJdCSXud1aHkNqTHk5WKZYnoW9EM3wqOz81RNON5nE9EJ3Z8MJhgwZ4jXFHGxqq7orZdzOAbHIQHkmWsFXYrbChQb8dGVeJeFHn2BZqg7TjZJPhQVmoWXgtnudeQCc1gQIbEjAMGiP1bp9smG(LXboM3Z8oGqam0UArUfeVN5nhpmSMXtI)cbVGG2DIMhI3Z8gAV)(G8GCSvaL4mzbEfl5EhL3cnDVJY7acbWq7kntqK06GNEjgqtEYOfZ7O8EJsYYBL7nmaHiEdT3q793hKhKJTcOeNjlWRyj37O8wOP7DuEhqiagAxPzcIKwh80lXaAYtgTyEdL34eV3OKS8gkVXH3zklVvU3q79gVN3BO92IoNqLRFihTqWlj)RdE6LyaMMyfUEJ3jEJhVHYBO8wHcVH27n6nZH3k3BO9(7dYdYXwbuIZKf4vSK7DuEl009gkVJY7acbWq7kntqK06GNEjgqtEYOfZ7O8EJsYYBL7nmaHiEdT3q79g9M5WBL7n0E)9b5b5yRakXzYc8kwY9okVfA6EdL3r5DaHayODLMjisADWtVedOjpz0I5nuEJt8EJsYYBO8gkVXH3q793hKhKJTcOeNjlWRyj37O8wOP7DuEhqiagAxPzcIKwh80lXaAYtgTyEhL3BuswERCVHbieXBO9gAV)(G8GCSvaL4mzbEfl5EhL3cnDVJY7acbWq7kntqK06GNEjgqtEYOfZBO8gN49gLKL3q5nuEd1q1ccfvdvGLHT44jmziJ92OKX0d1xgh4yJPgQbcvoHAd1i8wmWlrZeejTo4PxIb0VmoWX8EM3becGH2vlYTG49mV54HH1mEs8xi4fe0Ut08q8EM3q793hKhKJTcOeNjlWRyj37O8wOP7DuEhqiagAxPHPKVo4PxIb0KNmAX8okV3OKS8w5EddqiI3q7n0E)9b5b5yRakXzYc8kwY9okVfA6EhL3becGH2vAyk5RdE6Lyan5jJwmVHYBCI3BuswEdL34W7mLL3k3BO9EJ3Z7n0EBrNtOY1pKJwi4LK)1bp9smattScxVX7eVXJ3q5nuERqH3q79g9M5WBL7n0E)9b5b5yRakXzYc8kwY9okVfA6EdL3r5DaHayODLgMs(6GNEjgqtEYOfZ7O8EJsYYBL7nmaHiEdT3q79g9M5WBL7n0E)9b5b5yRakXzYc8kwY9okVfA6EdL3r5DaHayODLgMs(6GNEjgqtEYOfZBO8gN49gLKL3q5nuEJdVH27VpipihBfqjotwGxXsU3r5Tqt37O8oGqam0UsdtjFDWtVedOjpz0I5DuEVrjz5TY9ggGqeVH2BO9(7dYdYXwbuIZKf4vSK7DuEl009okVdieadTR0WuYxh80lXaAYtgTyEdL34eV3OKS8gkVHYBOgQwqOOAOcSmSfhpHjdzS3M5ym9q9LXbo2yQHAGqLtO2qLJhgwZ4jXFHGxqq7orZdzOAbHIQHkGgNlfTIxCiGmKXEB2VJPhQVmoWXgtnudeQCc1gQbecGH2vlYTGmuTGqr1qfyzyloEctgYyVnkZX0d1xgh4yJPgQbcvoHAdvYHjNLBCG79mVJWBoEyynJNe)fcEbbT7enpKHQfekQgQWal9flhfWDOgWpa(sms8f2yVndzS3M9Fm9q9LXbo2yQHAGqLtO2qvmWlrli5PvYyYj4RFzCGJ59mVH2BoEyyn5muzv4lbjpPjpz0I5no8Eo8wHcVH2BoEyyn5muzv4lbjpPjpz0I5no8gAV54HH1gl8cZQW1y8etOOY759oGqam0UsBSWlmRcxtEYOfZBO8EM3becGH2vAJfEHzv4AYtgTyEJdV3OeVHYBOgQwqOOAOki5PvYyYj4pKXE4jRX0d1xgh4yJPgQbcvoHAdvXaVennCyEc(6xgh4yEpZBoEyynnCyEc(AEiEpZBO9MJhgwtdhMNGVM8KrlM34W74aM3k37m7TY9MJhgwtdhMNGVMjwaxVvOWBoEyyntqKeU)qorZdXBfk8ocVfd8s0jJjNSqWlj)RdE6LW0VmoWX8gQHQfekQgQWeetwSCua3Hm2dpBgtpuFzCGJnMAOgiu5eQnufd8s00WH5j4RFzCGJnuTGqr1qLgompb)Hm2dp4zm9q1ccfvdvanoxkAfV4qazO(Y4ahBm1qg7HNmnMEOMqzqR4H6MHQfekQgQWal9flhfWDOgWpa(sms8f2yVnd1xgh4yJPgQbcvoHAdvYHjNLBCGpKXE4jZJPhQjug0kEOUzO(Y4ahBm1q1ccfvdvyGL(ILJc4oudeQCc1gQjugp9s0yuMyv4EJxVNJHm2dpkzm9qnHYGwXd1ndvliuunuHjiMSy5OaUd1xgh4yJPgYqgQg6JPh7Tzm9q9LXbo2yQHAGqLtO2qvmWlrZeejH7pKt0VmoWXgQwqOOAOYeejH7pKtgYyp8mMEO(Y4ahBm1qnqOYjuBOsom5SCJdCVN5n0EZGCayjgj(cthYnATa04CPOvS34WBO9wjEhL3r4TyGxIwqYtRKXKtWx)Y4ahZBO8wHcVJWBXaVentqK06GNEjgq)Y4ahZ7zEdT3WuYxh80lXaAYtgTyEJxVH27nz2BL7ndYbGvUXK7nuERqH3becGH2vAyk5RdE6Lyan5jJwmVXH3q7nEYS3r59Mm7TY9Mb5aWk3yY9gkVHYBO8EM3q7DeElg4LOzcIKwh80lXa6xgh4yERqH3mbrsRdE6LyangAx5TcfEZGCayjgj(cthYnATa04CPOvS3t8otEpZBoEyy9oAHTI5zIMjwaxVXH3BYS3qnuTGqr1qfgyPVy5OaUd1a(bWxIrIVWg7TziJ9Y0y6H6lJdCSXud1aHkNqTHQyGxI2yHxywfU(LXboM3Z8gAVfd8s0mbrsRdE6Lya9lJdCmVN5ntqK06GNEjgqJH2vEpZ7acbWq7kntqK06GNEjgqtEYOfZB869gL4TcfEhH3IbEjAMGiP1bp9smG(LXboM3q59mVH27i8wmWlrtdhMNGV(LXboM3ku4DeEZXddRPHdZtWxZdX7zEhH3becGH2vAA4W8e818q8gQHQfekQgQgl8cZQWhYyVmpMEO(Y4ahBm1qnqOYjuBOkg4LObuCgpfBLS4KTeK8K(LXbo2q1ccfvdvafNXtXwjlozlbjpnKXEkzm9q9LXbo2yQHAGqLtO2qncVfd8s0jJjNSqWlj)RdE6LW0VmoWX8wHcV54HH1mbrs4(d5enpeVvOW7KDatiOK34DI3q79MSYY7O8oZERCVzqoaSeJeFHPd5gTwaACUu0k2BO8wHcV54HH1jJjNSqWlj)RdE6LW08q8wHcVzqoaSeJeFHPd5gTwaACUu0k2B86DMgQwqOOAOEJi54mEd3pKXEZXy6H6lJdCSXud1aHkNqTHkhpmSMjisc3FiNOjpz0I5no8otERCVJdyERCV54HH1mbrs4(d5entSaUdvliuunud5gTwaACUu0kEiJ92VJPhQVmoWXgtnudeQCc1gQC8WWAGLHTy8K4R5H49mVzqoaSeJeFHPd5gTwaACUu0k2BC4DM9EM3q7DeElg4LOzcIKwh80lXa6xgh4yERqH3mbrsRdE6LyangAx5nuEpZBmKOHbw6lwokGRwObCPv8q1ccfvdvGLHT44jmziJ9uMJPhQVmoWXgtnudeQCc1gQmihawIrIVW0HCJwlanoxkAf7no8oZEpZ7i8MJhgwBSWlmRcxZdzOAbHIQHknCyEc(dzS3(pMEO(Y4ahBm1qnqOYjuBOYGCayjgj(cthYnATa04CPOvS34W7m79mV54HH10WH5j4R5H49mVJWBoEyyTXcVWSkCnpKHQfekQgQWeetwSCua3Hm2BtwJPhQVmoWXgtnudeQCc1gQIbEj6dE6LyGfhWyI(LXboM3Z8Mb5aWsms8fMoKB0AbOX5srRyVXH3z27zEdT3r4TyGxIMjisADWtVedOFzCGJ5TcfEZeejTo4PxIb0yODL3qnuTGqr1q9GNEjgyXbmMmKXEB2mMEO(Y4ahBm1qnqOYjuBOkg4LOnw4fMvHRFzCGJnuTGqr1qfyzylUBPHm2BdEgtpuTGqr1qnKB0AbOX5srR4H6lJdCSXudzS3MmnMEOMqzqR4H6MH6lJdCSXudvliuunubwg2IJNWKHAGqLtO2qvmWlrBSWlmRcx)Y4ahBiJ92K5X0d1ekdAfpu3muTGqr1qfgyPVy5OaUd1a(bWxIrIVWg7TzO(Y4ahBm1qnqOYjuBOsom5SCJd8Hm2BJsgtputOmOv8qDZq1ccfvdvycIjlwokG7q9LXbo2yQHmKHk2HnEGmMES3MX0d1xgh4ydUHAGqLtO2q1IoNqLRTkCMqmWICgQSkC9lJdCSHQfekQgQCaecdWZKHm2dpJPhQVmoWXgtnudeQCc1gQFFqEqo2kGsCMSaVILCVJYBHMU34W7mLL3ku4nmL81bp9smGMhI3ku4ntqK06GNEjgqZdzOAbHIQHkeKqr1qg7LPX0dvliuunu3rlSfl)gzO(Y4ahBm1qg7L5X0d1xgh4yJPgQbcvoHAdvXaVeTGKNwjJjNGV(LXboM3Z8MJhgwtodvwf(sqYtAYtgTyEJdVXZq1ccfvdvbjpTsgtob)Hm2tjJPhQVmoWXgtnudeQCc1gQr4TyGxIMjisADWtVedOFzCGJnuTGqr1qfMs(6GNEjgyiJ9MJX0d1xgh4yJPgQbcvoHAdvXaVentqK06GNEjgq)Y4ahZ7zEdT3r4TyGxIMgompbF9lJdCmVvOW7i8MJhgwtdhMNGVMhI3Z8ocVdieadTR00WH5j4R5H4nudvliuunuzcIKwh80lXadzS3(Dm9q1ccfvdvE2xu5j2q9LXbo2yQHm2tzoMEO(Y4ahBm1qnqOYjuBOgH3IbEjAJfEHzv46xgh4yERqH3C8WWAJfEHzv4AEiERqH3becGH2vAJfEHzv4AYtgTyEJxVvswdvliuunu5aie2cMNG)qg7T)JPhQVmoWXgtnudeQCc1gQr4TyGxI2yHxywfU(LXboM3ku4nhpmS2yHxywfUMhYq1ccfvdvUtyNGlTIhYyVnznMEO(Y4ahBm1qnqOYjuBOgH3IbEjAJfEHzv46xgh4yERqH3C8WWAJfEHzv4AEiERqH3becGH2vAJfEHzv4AYtgTyEJxVvswdvliuunuHPKZbqiSHm2BZMX0d1xgh4yJPgQbcvoHAd1i8wmWlrBSWlmRcx)Y4ahZBfk8MJhgwBSWlmRcxZdXBfk8oGqam0UsBSWlmRcxtEYOfZB86TsYAOAbHIQHQvHZeIbwbdagYyVn4zm9q9LXbo2yQHAGqLtO2qLjisADWtVedO5H49mV54HH1bdawaACUu0kwtEYOfZB8oXBL5q1ccfvd1J)xi4LK)ftqK0qg7TjtJPhQwqOOAOMUCezO(Y4ahBm1qg7TjZJPhQVmoWXgtnuTGqr1qLWxlliuuTauMmudeQCc1gQwqOz81RNON5nE9gpEpZBO9Mb5aWsms8fMoKB0AbOX5srRyVXR34XBfk8Mb5aWsms8fMgyzylUBjVXR34XBOgQaktwLL(q1qFiJ92OKX0d1xgh4yJPgQwqOOAOs4RLfekQwaktgQaktwLL(qLrRyWxIrIVmKHmuHqEaL4mzm9yVnJPhQVmoWXgtnKXE4zm9q9LXbo2yQHm2ltJPhQVmoWXgtnKXEzEm9q9LXbo2yQHm2tjJPhQwqOOAOki5PvYyYj4puFzCGJnMAiJ9MJX0d1xgh4yJPgQbcvoHAd1i8wmWlrdHqtgyDWtVedqzI(LXbo2q1ccfvd1BejFDWtVedmKXE73X0d1xgh4yJPgQbcvoHAdvXaVentqKeU)qor)Y4ahZ7zEdT3eJITEgVeTHHX0beFjEJdVZK3ku4nXOyRNXlrByymnT8gVERKS8gQHQfekQgQmbrs4(d5KHm2tzoMEO(Y4ahBm1qnqOYjuBOgH3IbEjAMGiP1bp9smG(LXbo2q1ccfvdvyk5RdE6LyGHm2B)htpuFzCGJnMAOgiu5eQnufd8s0mbrsRdE6Lya9lJdCSHQfekQgQmbrsRdE6LyGHm2BtwJPhQwqOOAOcbjuunuFzCGJnMAiJ92Szm9q9LXbo2yQHAGqLtO2qvmWlrFWtVedS4agt0VmoWX8EM3mihawIrIVW0HCJwlanoxkAf7no8otdvliuunup4PxIbwCaJjdzS3g8mMEO(Y4ahBm1qnqOYjuBOgH3IbEj6dE6LyGfhWyI(LXboM3Z8Mb5aWsms8fMoKB0AbOX5srRyVXH3zAOAbHIQHkWYWwC8eMmKXEBY0y6H6lJdCSXud1aHkNqTHkdYbGLyK4lmDi3O1cqJZLIwXEJxVXZq1ccfvd1qUrRfGgNlfTIhYqgYq14LCezOQst8atOOszHyWYqgYya]] )


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
