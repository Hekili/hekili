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


    spec:RegisterPack( "Elemental", 20190310.0123, [[d8KJQbqisjpsiLlbvPSjPIpbvugfi1PajRsi0RukmlPsULcyxK8lfIHjKCmLsldQWZuGmnfOUgPu2gPu13GQenoLQsDoOIQ1PuvX7GQeO5PuL7PG2hufhuivSqPs9qsPsnrHuvxuiyJkvv6JqvcnsOkbCsHuPvQu5LKsL0mHQuDtLQIDQu0pjLkXqHQKwQsvj9us1uviDvHuLVQuvIXcvjO9QO)QKbl6Wuwms9ybtgkxw1Mb1NfQrlvDAu9AOsZg42sz3s(nKHdIJtkvSCephLPtCDKSDHOVRqnEOICEOQwVsvvZNuSFQEUDo6uhZKp3ehrTfNh1GWH2R2QTTAtB4yQl4d5tDiwaxl(t9YAFQhbWBVedm1Hy4dqg2C0PodrrcFQ3lce2(zKrI5spfTkGAJW4nkGjCufigSmcJ3cJm1PP4aj6wt6PoMjFUjoIAlopQbHdTxTvBB12G23tDgKhMBIdThht9Eog2Rj9uh7SWupAEgbWBVed4PEV1SY3fnp7fbcB)mYiXCPNIwfqTry8gfWeoQcedwgHXBHr8DrZZ9XiHEp3gvxEIJO2IZ9CapJA7(bhB9D(UO5P2DVvXNTF8DrZZb8m6XUN4fUo4TxIbuuq8Kys)jEk9w5zO)bC5vSNbecGHgxmpfKNSFp5WEEWBVedW80i3tli8iVY3fnphWZOpNz0GJ5zemI07zeaV9smGNVec)mLVlAEoGN7RVHI8EgDyHxywfUNcV9r6gV7zO)bCv(UO55aEgDWW8mc4FprWEk93tDbrAEoIN7ZLJiQPoeccMd(upAEgbWBVed4PEV1SY3fnp7fbcB)mYiXCPNIwfqTry8gfWeoQcedwgHXBHr8DrZZ9XiHEp3gvxEIJO2IZ9CapJA7(bhB9D(UO5P2DVvXNTF8DrZZb8m6XUN4fUo4TxIbuuq8Kys)jEk9w5zO)bC5vSNbecGHgxmpfKNSFp5WEEWBVedW80i3tli8iVY3fnphWZOpNz0GJ5zemI07zeaV9smGNVec)mLVlAEoGN7RVHI8EgDyHxywfUNcV9r6gV7zO)bCv(UO55aEgDWW8mc4FprWEk93tDbrAEoIN7ZLJikFNVlAEgbC6bk5yEsFye5EgqnAt8K(X8IP8m6echIW8Sq1a9gPbtb80cchvmprfaFLVZcchvmfeYdOgTjdHbgdxFNfeoQykiKhqnAt2y4iWieMVZcchvmfeYdOgTjBmCeJkU9smHJkFNVlAEQxgewps8KyCmpPPGHpMNmXeMN0hgrUNbuJ2epPFmVyEAfMNqiFaiir4vSNCMNyO6kFNfeoQykiKhqnAt2y4iSYGW6rYIjMW8Dwq4OIPGqEa1OnzJHJii5TvZyYj477SGWrftbH8aQrBYgdh5gr6xh82lXaDXHhQLyGxIccH3mW6G3EjgGZe1lJgCmFNVlAEg9y3tDbrA4(d5epHqEa1OnXtQcCgZtgQDpnmmMNJ5aGNmi24YtgcvkFNfeoQykiKhqnAt2y4imbrA4(d5KU4Wdfd8sumbrA4(d5e1lJgCSoqtmo26r(sugggtfquLS3G0OHyCS1J8LOmmmMIx4rBrbLVZ3zbHJkMcc5buJ2KngocmN81bV9smqxC4HAjg4LOycI0wh82lXaQxgn4y(oliCuXuqipGA0MSXWrycI0wh82lXaDXHhkg4LOycI0wh82lXaQxgn4y(oliCuXuqipGA0MSXWrGGeoQ8Dwq4OIPGqEa1OnzJHJCWBVedSObgt6IdpumWlrDWBVedSObgtuVmAWX8Dwq4OIPGqEa1OnzJHJaSiTfnfHjDXHhQLyGxI6G3EjgyrdmMOEz0GJ1Hb5aWsms8fMk0B8Ab4X9sXR49gKVZcchvmfeYdOgTjBmCKqVXRfGh3lfVI7IdpKb5aWsms8fMk0B8Ab4X9sXRy8GdFNVlAEgbC6bk5yE(ipbFpfE7Ek93tliiINCMNwKghy0GR8DrZtTBJjE2naHWaumXZMvugaGVNCypL(7z0z)pHl3Zrjgx8m6uHZeIb8CF9muzv4EYzEcHC2lr57SGWrfBinaHWaumPlo8qB)pHlxzv4mHyGf5muzv4Qxgn4y(oFx08m6wdeqnAt8ecs4OYtoZtiKdFYlHBaa(Ec4fUhZtb5j(ikINra82lXaD5jvboJ5za1OnXZXCaWZxyEY6rebGVVZcchvSngoceKWrvxC4HhNG8GCSva1OnzbEfl9di823BqrPrdmN81bV9smGIcIgnmbrARdE7LyaffeFNVlAEgDl5ecfeXteSNbJjmLVZcchvSngoYyEHTy93i(oFNfeoQyBmCebjVTAgtob)U4Wdfd8sucsEB1mMCc(Qxgn4yDOPGHvKZqLvHVeK8MI8MXl2E4W3zbHJk2gdhbMt(6G3EjgOlo8qTed8sumbrARdE7Lya1lJgCmFNfeoQyBmCeMGiT1bV9smqxC4HIbEjkMGiT1bV9smG6LrdowhO1smWlrXdhMIGV6LrdoMgnArtbdR4HdtrWxrbPJwbecGHgxkE4Wue8vuqGQd0Ajg4LOmw4fMvHREz0GJPrJwbecGHgxkJfEHzv4kkiD0IMcgwzSWlmRcxrbbkFx080cchvSngoYnI0Vo4TxIb6IdpulXaVefecVzG1bV9smaNjQxgn4yA0ig4LOGq4ndSo4TxIb4mr9YObhRd0becGHgxkyo5RdE7Lyaf5nJxS92IJO6OLyGxIIjisBDWBVedOEz0GJPrtaHayOXLIjisBDWBVedOiVz8IT3wCevhXaVeftqK26G3Ejgq9YObhdkFNfeoQyBmCek2xC5nMVZcchvSngocnaHWwWue87IdpulXaVeLXcVWSkC1lJgCmnAOPGHvgl8cZQWvuq0OjGqam04szSWlmRcxrEZ4fdpAlkFNfeoQyBmCe6tyNGlVI7IdpulXaVeLXcVWSkC1lJgCmnAOPGHvgl8cZQWvuq8Dwq4OITXWrG5KtdqiSU4Wd1smWlrzSWlmRcx9YObhtJgAkyyLXcVWSkCffenAcieadnUugl8cZQWvK3mEXWJ2IY3zbHJk2gdhXQWzcXaRGbaDXHhQLyGxIYyHxywfU6LrdoMgn0uWWkJfEHzv4kkiA0eqiagACPmw4fMvHRiVz8IHhTfLVZcchvSngoYX)le8s6)IjisRlo8qMGiT1bV9smGIcshAkyyvWaGfGh3lfVIvK3mEXWZW9TVZcchvSngos7YreFNfeoQyBmCecvTSGWr1cWzsxL1(qd9U4WdTGWJ8RxVXpdp4Od0mihawIrIVWuHEJxlapUxkEfJhCOrddYbGLyK4lmfWI0w03A4bhq57SGWrfBJHJqOQLfeoQwaot6QS2hY4vm4lXiXx8D(UO55(qbeUNIrIV4PfeoQ8ecHJiCbFpbCM47SGWrftzOpKjisd3FiN0fhEOyGxIIjisd3FiNOEz0GJ578DrZtDiKByEUFbw7EQ3Jc46jV8CVHEoypfJeFXtyECVW6YtAkXZcjEIrr4vSN6rWtkicV9UOkWzmpXhrHZi3tyECVWRyphKNIrIVW80kmp7TiVNGZyEk9w552b75(cVW8eVift8KjwaxMY3zbHJkMYqFJHJadS2xSEua3Uc4haFjgj(cB42U4WdjhMCwVrdEhOzqoaSeJeFHPc9gVwaECVu8kEpO12aAjg4LOeK82Qzm5e8vVmAWXGsJgTed8sumbrARdE7Lya1lJgCSoqdZjFDWBVedOiVz8IHhO3o4iYGCay1Bm5qPrtaHayOXLcMt(6G3EjgqrEZ4fBpOXXGhy7GJidYbGvVXKdfuq1bATed8sumbrARdE7Lya1lJgCmnAycI0wh82lXakm04sJggKdalXiXxyQqVXRfGh3lfVIhoOo0uWWQX8cBftXeftSaU7TDWq57SGWrftzOVXWrmw4fMvH3fhEOyGxIYyHxywfU6LrdowhOfd8sumbrARdE7Lya1lJgCSombrARdE7LyafgAC1jGqam04sXeePTo4TxIbuK3mEXWZwTPrJwIbEjkMGiT1bV9smG6LrdoguDGwlXaVefpCykc(Qxgn4yA0OfnfmSIhomfbFffKoAfqiagACP4HdtrWxrbbkFNfeoQykd9ngocGRDO4yRMf3SLGK36IdpumWlrb4Ahko2QzXnBji5n1lJgCmFNVlAEokbFpfKNXw7EgbJi9Ahkd375yU075(ym5eprWEk93ZiaE7LW8KMcg2ZX9V8eMh3l8k2Zb5PyK4lmLNrFuHZeprrEsWG45(yhWecQPLVZcchvmLH(gdh5gr61ougUVlo8qTed8sunJjNSqWlP)RdE7LWuVmAWX0OHMcgwXeePH7pKtuuq0OPzhWecQHNHqVnQOgyWrKb5aWsms8fMk0B8Ab4X9sXRyO0OHMcgw1mMCYcbVK(Vo4TxctrbrJggKdalXiXxyQqVXRfGh3lfVIXZG8D(UO55(y4EpzuK7j(ikpXqfot8eGy3tZtDbrA4(d5eLVZcchvmLH(gdhj0B8Ab4X9sXR4U4WdPPGHvmbrA4(d5ef5nJxS9gueJdyrKMcgwXeePH7pKtumXc4678DrZtTlfaFpdgt8eVBrAE2nfHjEIkpLEYVNIrIVW8Kd7jx8KZ80kp5ftSs80kmp1feP5zeaV9smGNCMNBQDzupTGWJ8kFNfeoQykd9ngocWI0w0ueM0fhEinfmScyrAlgfj(kkiDyqoaSeJeFHPc9gVwaECVu8kEVb3bATed8sumbrARdE7Lya1lJgCmnAycI0wh82lXakm04cQoyirbdS2xSEuaxLWd4YRyFNfeoQykd9ngocpCykc(DXHhYGCayjgj(ctf6nETa84EP4v8EdUJw0uWWkJfEHzv4kki(oliCuXug6BmCeycIjlwpkGBxC4HmihawIrIVWuHEJxlapUxkEfV3G7qtbdR4HdtrWxrbPJw0uWWkJfEHzv4kki(oFx08m6XUNra82lXaE2nWyINwSXlM4jfepfKNdYtXiXxyEAmpbOk2tJ5PUGinpJa4TxIb8KZ8SqINwq4rELVZcchvmLH(gdh5G3EjgyrdmM0fhEOyGxI6G3EjgyrdmMOEz0GJ1Hb5aWsms8fMk0B8Ab4X9sXR49gChO1smWlrXeePTo4TxIbuVmAWX0OHjisBDWBVedOWqJlO8Dwq4OIPm03y4ialsBrFR1fhEOyGxIYyHxywfU6LrdoMVZcchvmLH(gdhj0B8Ab4X9sXRyFNfeoQykd9ngocWI0w0ueM0vdfjVIhUTlo8qXaVeLXcVWSkC1lJgCmFNfeoQykd9ngocmWAFX6rbC7QHIKxXd32va)a4lXiXxyd32fhEi5WKZ6nAW9Dwq4OIPm03y4iWeetwSEua3UAOi5v8WT(oFx08uNxXG75Ogj(INrNGWrLN4vchr4c(EI35mX3fnpJqXOi3Z9RUNCMNwq4rEpPkWzmpXhr5zVf59C7G9er8SHi3tMybCzEIG9CFHxyEIxKIjEctqnp1feP5zeaV9smGYtOJaw89mySVF8Kcsa14vSNrhwWtAkXtli8iVN6raVGEIHkCM4ju(oliCuXumEfd(sms8LHWaR9fRhfWTlo8qO1s4bC5vSgnIbEjkMGiT1bV9smG6LrdowNacbWqJlftqK26G3EjgqrEZ4fBpCeX4aMgnyirbdS2xSEuaxf5nJxS9gghW0OrmWlrzSWlmRcx9YObhRdgsuWaR9fRhfWvrEZ4fBpOdieadnUugl8cZQWvK3mEX2GMcgwzSWlmRcxHrrmHJkO6eqiagACPmw4fMvHRiVz8IT3G7aTwIbEjkMGiT1bV9smG6LrdoMgnIbEjkMGiT1bV9smG6LrdowNacbWqJlftqK26G3EjgqrEZ4fBVT4ikOGQd00uWWQX8cBftXeftSaU7TDWA0y7)jC5kECDefBbbjVeUbueRWfpdXHgn0uWWkGfPTyuK4ROGOrJw0uWWkAacHbOyIIccuD0IMcgwXOiXFHGxqqJprrbX357IMNrp29m6WcVWSkCpny5epXhrHZI8EYG8s80aapX7wKMNDtryINHEJeFMNwH5jQa47jh2Z6CP)ep1feP5zeaV9smGNfI4z0nCykc(EAK7zGIqEja890ccpYR8Dwq4OIPy8kg8LyK4lBmCeJfEHzv4DXHhkg4LOmw4fMvHREz0GJ1jGqam04sbSiTfnfHjkYBgVy4jQoqhqiagACPycI0wh82lXakYBgVy7TfhrPrJwIbEjkMGiT1bV9smG6LrdoguDGwlXaVefpCykc(Qxgn4yA0OfnfmSIhomfbFffKoAfqiagACP4HdtrWxrbbkFNVlAEg9rfot8KIDpJa4TxIb8SBGXep5WEIpIYZaIcG5zWyINMN7JXKt8eb7P0FpJa4TxcZZ3GGgFYX8mcgr69uVhfW1tEXKBykpJ(OcNjEgmM4zeaV9smGNDdmM4jgfHxXEQlisZZiaE7LyapPkWzmpXhr5zVf59Cq4KNBAcfXaEIxaJ0qf(kp7Ms8KxEk9CMNbJDpzccINumEf7zeaV9smGNDdmM4jQc3t8ruEsUf69C7G9KjwaxMNiyp3x4fMN4fPyIY3zbHJkMIXRyWxIrIVSXWro4TxIbw0aJjDXHhkg4LOo4TxIbw0aJjQxgn4yDGwmWlr1mMCYcbVK(Vo4Txct9YObhRdnfmSQzm5KfcEj9FDWBVeMIcsNMDatiO2EAFuA0OLyGxIQzm5KfcEj9FDWBVeM6LrdoguDGwlOzcI0wh82lXakkiDed8sumbrARdE7Lya1lJgCmO0OX2)t4YvLjuedS6nsdv4RiwH7Wb1HMcgwnMxyRykMOyIfWDVTdgkFNVlAEQD9hIN6Ax9egr8eyK47jI4jdHkpnmmphBrEMYZOxboJ5j(ikp7TiVN6uK47jc2t8kA8jD5jV8CCpp07zWy3t8ruEo2kXtb5jgIIgCpPPGH9eVZJ7LIxXE2nciEsJVNqqiaVI9CFSdycb18K(WiY7Tct5zeWjRbbCpzx7q9k89JNBJkQ9rVlpJGExEQRDTlpX7D3LN49i7UlpJGExEI3723zbHJkMIXRyWxIrIVSXWrycI0W9hYjDXHhkg4LOycI0W9hYjQxgn4yDGMyCS1J8LOmmmMkGOkzVbPrdX4yRh5lrzyymfVWJ2IcQoqRLyGxIIrrI)cbVGGgFI6LrdoMgn0uWWkgfj(le8ccA8jkkiA00Sdycb1WZWbpyO8D(oliCuXumEfd(sms8LngocGRDO4yRMf3SLGK36IdpumWlrb4Ahko2QzXnBji5n1lJgCSoqtmo26r(sugggtfquLS3G0OHyCS1J8LOmmmMIx4rBrbLVZ3fnp1UrnAEDp1fePH7pKt8Cmx69CFmMCINiypL(7zeaV9syEIiEQtrIVNiypXROXNO8Dwq4OIPy8kg8LyK4lBmCeapUxkEfVOraPlo8qAkyyftqKgU)qorrbPddYbGLyK4lmvO341cWJ7LIxX7HJoqttbdRAgtozHGxs)xh82lHPOG0rlXaVefJIe)fcEbbn(e1lJgCmnAOPGHvmks8xi4fe04tuuqGY357IMNJ2FY9SXJ7fpdO290kpPGGzY9egr8u65mpb86EoMl9EYqT7PocV6jafZdkFNfeoQykgVIbFjgj(Ygdh5gr61ougUVlo8qgKdalXiXxyQqVXRfGh3lfVIXZ2oqRLyGxIIrrI)cbVGGgFI6LrdoMgnAHHefmWAFX6rbCvKdtoR3ObxJgMGiT1bV9smGIccuDGwlXaVevZyYjle8s6)6G3Ejm1lJgCmnAOPGHvnJjNSqWlP)RdE7LWuuq0OPzhWecQHNH4CCaLVZ3fnp3x4sVN7JXKt8eb7P0FpJa4TxcZt8ruEgSYtiieWZ9XoGjeuZtkiEkip33EUp2bmHGAEsFaASNs)9myq8uqE(IrrUNCH5jf7EoMl9EgbJi9EQ3Jc4Q8m6JkCM4jkYtgt4Y9uNIeFprWEIxrJpXtAkyyMYZOloR5jaHWLxXEAIN4JO8m6alNW6rbC1Y3zbHJkMIXRyWxIrIVSXWrUrK(fRhfWTlo8qTOPGHvmks8xi4fe04tuuq6ig4LOAgtozHGxs)xh82lHPEz0GJ1bAAkyyvZyYjle8s6)6G3EjmffenAcieadnUualsBrtryII8MXlgEIQtZoGjeudpdX54yJbfvefd8subdaws)xspvHDI6LrdoMgn0uWWkMGinC)HCIIcsNacbWqJlfWI0w0ueMOiVz8IT3W4agu(oFx08CFHl9ikXZ9XyYjEIG9u6VNra82lH1LNuS7zemI07PEpkGRNNl9N4jh2tDbrA4(d5ep5mpPG0LN7JDatiOMNCMNJ5spV8CBuEUp2bmHGAEIG9u6VNbdsxEIiEEU0FIN6cI08mcG3EjgWtoRWzINIbEjhZteXtUGZyEwiXtli8iVNwH5j(ikINaJjEQlisZZiaE7LyaprWEk93tyECV45yoa4zVf59eva8908eIreUb8eJIychvEcneafZtP)EgHqpYteSNs)9mcG3EjgG5jgfXeoQGs5z0f2t8ruE2BrEpJUX1rumpXRi5LWnGNdYtH3oRlpXqfot8KIDpJGrKEwpkGRNyueEf7z0HfEHzv4kFNfeoQykgVIbFjgj(Ygdh5gr6xSEua3U4Wd1smWlr1mMCYcbVK(Vo4Txct9YObhRJwqB7)jC5kECDefBbbjVeUbueRWfp4OdnfmSYyHxywfUIccuDGMMcgwXeePH7pKtuuq0OPzhWecQHNH48O2yqrfrXaVevWaGL0)L0tvyNOEz0GJPrJwqZeePTo4TxIbuuq6ig4LOycI0wh82lXaQxgn4yq154eKhKJTcOgTjlWRyPFaH3(abecGHgxkMGiT1bV9smGI8MXl2aB1wuregGqeOH(4eKhKJTcOgTjlWRyPFaH3(abecGHgxkMGiT1bV9smGI8MXlgu4TTAlkOWZWbfveHE7gqB7)jC5Qh6rle8s6)6G3EjgGPiwHlEgIdOGckFNVlAEg9y3ZiyeP3t9Euaxp5WEQtrIVNiypXROXN4jN5PyGxYX6YtAkXZ6CP)ep5INfI4P5z0hVQ7zeaV9smGNCMNwq4rEpnXtP)E2qTxsxEAfMN4DlsZZUPimXtoZtYnm89er8Cmha8K(EsUHHVNJ5spV8u6VN1XjXt8IA3rFLVZcchvmfJxXGVeJeFzJHJCJi9lwpkGBxC4HIbEjkgfj(le8ccA8jQxgn4yD0IMcgwXOiXFHGxqqJprrbPtaHayOXLcyrAlAkctuK3mEX2ByCaRd0Ajg4LOycI0wh82lXaQxgn4yD0cMt(6G3EjgqrbrJgXaVeftqK26G3Ejgq9YObhRJwmbrARdE7LyaffeO8D(UO5PoeR5jENh3lfVI9SBeqyEIrr4vSN6cI08mcG3EjgWtmkIjCu5jh2t8ruEIHkCM4zVf59m6gxhrX8eVIKxc3aEIiE2BrEp5INOcGVNOk8U80kmpXqfot8KIDpX784EP4vSNDJaINyueEf7z3aecdqXep5WEIpIYZElY7P5jE3I08uNIeFpXReuq57SGWrftX4vm4lXiXx2y4iaECVu8kErJasxC4HmbrARdE7LyaffKoIbEjkMGiT1bV9smG6LrdowhOT9)eUCfpUoIITGGKxc3akIv4Uho0OrlAkyyfWI0wmks8vuq6qtbdRObiegGIjkkiq578DrZZOh7EUFjiM4PEpkGRNJ5sVNr3WHPi47PvyEUpgtoXteSNs)9mcG3EjmLVZcchvmfJxXGVeJeFzJHJatqmzX6rbC7IdpumWlrXdhMIGV6LrdowhXaVevZyYjle8s6)6G3Ejm1lJgCSo0uWWkE4Wue8vuq6qtbdRAgtozHGxs)xh82lHPOG478Dwq4OIPy8kg8LyK4lBmCeGfPTOPimPlo8qAkyyLXcVWSkCffeFNVlAEg9eoGV)3tDks89eb7jEfn(epfKNmiKByEUFbw7EQ3Jc46jh2Zgfq4qa3ZxVXpZtJCpHqo7LO8Dwq4OIPy8kg8LyK4lBmCeyG1(I1Jc42va)a4lXiXxyd32fhEi5WKZ6nAW7ybHh5xVEJFgE22HMcgwXOiXFHGxqqJprrbX357IMNrp29eVBrAE2nfHjEoMl9EQtrIVNiypXROXN4jh2tP)EcmM4jeK8s4gWtkMfFprWEAEQlisZZiaE7Lyap7nwHZepnpHPaapXOiMWrLNAx2x9Kd7j(ikpdikaMNXx80kK0FINuml(EIG9u6VNrF8QUNra82lXaEYH9u6VNK3mEXRypH5X9INJnMNB1E8MNaufFIY3zbHJkMIXRyWxIrIVSXWrawK2IMIWKU4Wdfd8sumbrARdE7Lya1lJgCSobecGHgxlYTG0HMcgwXOiXFHGxqqJprrbPd0hNG8GCSva1OnzbEfl9di82hiGqam04sXeePTo4TxIbuK3mEXgyR2IkIWaeIan0hNG8GCSva1OnzbEfl9di82hiGqam04sXeePTo4TxIbuK3mEXGcVTvBrb1EdkQic92nG22)t4Yvp0Jwi4L0)1bV9smatrScx8mehqbLgnqVvTv7Ji0hNG8GCSva1OnzbEfl9di82HAGacbWqJlftqK26G3EjgqrEZ4fBGTAlQicdqic0qVvTv7Ji0hNG8GCSva1OnzbEfl9di82HAGacbWqJlftqK26G3EjgqrEZ4fdk82wTffuqTh0hNG8GCSva1OnzbEfl9di82hiGqam04sXeePTo4TxIbuK3mEXgyR2IkIWaeIan0hNG8GCSva1OnzbEfl9di82hiGqam04sXeePTo4TxIbuK3mEXGcVTvBrbfuq578DrZZOh7EI3Tinp7MIWephZLEp1PiX3teSN4v04t8Kd7P0Fpbgt8ecsEjCd4jfZIVNiypnp3VCY9mcG3EjgWZEJv4mXtZtykaWtmkIjCu5P2L9vp5WEIpIYZaIcG5z8fpTcj9N4jfZIVNiypL(7z0hVQ7zeaV9smGNCypL(7j5nJx8k2tyECV45yJ55wThV5javXNO8Dwq4OIPy8kg8LyK4lBmCeGfPTOPimPlo8qTed8sumbrARdE7Lya1lJgCSobecGHgxlYTG0HMcgwXOiXFHGxqqJprrbPd0hNG8GCSva1OnzbEfl9di82hiGqam04sbZjFDWBVedOiVz8InWwTfveHbiebAOpob5b5yRaQrBYc8kw6hq4TpqaHayOXLcMt(6G3EjgqrEZ4fdk82wTffu7nOOIi0B3aAB)pHlx9qpAHGxs)xh82lXamfXkCXZqCafuA0a9w1wTpIqFCcYdYXwbuJ2Kf4vS0pGWBhQbcieadnUuWCYxh82lXakYBgVydSvBrfryacrGg6TQTAFeH(4eKhKJTcOgTjlWRyPFaH3oudeqiagACPG5KVo4TxIbuK3mEXGcVTvBrbfu7b9XjipihBfqnAtwGxXs)acV9bcieadnUuWCYxh82lXakYBgVydSvBrfryacrGg6JtqEqo2kGA0MSaVIL(beE7deqiagACPG5KVo4TxIbuK3mEXGcVTvBrbfuq578Dwq4OIPy8kg8LyK4lBmCeapUxkEfVOraPlo8qAkyyfJIe)fcEbbn(effeFNfeoQykgVIbFjgj(YgdhbyrAlAkct6IdpmGqam04ArUfKoAjg4LOAgtozHGxs)xh82lHPEz0GJ5780tFx08uhWJ7fa(EgBT7z0nCykc(Estbd7PG8Shb5Wuaa(Estbd7jd1UNVbbn(KJ55(LGyIN69OaUmphZLEp3hJjN4jc2tP)EgbWBVeMY3zbHJkMIXRyWxIrIVSXWr4HdtrWVlo8qXaVefpCykc(Qxgn4yD0c6MDatiOgEWl1wNacbWqJlfWI0w0ueMOiVz8IT3WOGQd0Ajg4LOycI0wh82lXaQxgn4yA0eqiagACPycI0wh82lXakYBgVy7TfhrbLVZ3zbHJkMIXRyWxIrIVSXWrawK2IMIWKU4WddieadnUwKBbPtO3iXNHhXaVe1d9OfcEj9FDWBVeM6LrdoMVZ3fnp1b84EbGVNyhy47jfJxXEgDdhMIGVNVbbn(KJ55(LGyIN69OaUmpfKNVbbn(epL(38Cmx69CFmMCINiypL(7zeaV9syEkiKY3zbHJkMIXRyWxIrIVSXWrGjiMSy9OaUDXHhkg4LO4HdtrWx9YObhRdnfmSIhomfbFffKo0uWWkE4Wue8vK3mEX2BRABeJdyrKMcgwXdhMIGVIjwaxFNVZcchvmfJxXGVeJeFzJHJaSiTfnfHjDXHhgqiagACTi3cIVZ3fnpJ(OcNjEAHah7Lyaa(EsXUN6uK47jc2t8kA8jEoMl9EUFbw7EQ3Jc46jgfHxXEY4vm4Ekgj(IY3zbHJkMIXRyWxIrIVSXWrGbw7lwpkGBxb8dGVeJeFHnCBxC4HKdtoR3ObVJw0uWWkgfj(le8ccA8jkki(oliCuXumEfd(sms8LngoIGK3wnJjNGFxC4HIbEjkbjVTAgtobF1lJgCSoqttbdRiNHkRcFji5nf5nJxS90EnAGMMcgwrodvwf(sqYBkYBgVy7bnnfmSYyHxywfUcJIychvBeqiagACPmw4fMvHRiVz8IbvNacbWqJlLXcVWSkCf5nJxS92QnOGY357SGWrftX4vm4lXiXx2y4iWeetwSEua3U4Wdfd8su8WHPi4REz0GJ1HMcgwXdhMIGVIcshOPPGHv8WHPi4RiVz8ITxCalIdoI0uWWkE4Wue8vmXc4QrdnfmSIjisd3FiNOOGOrJwIbEjQMXKtwi4L0)1bV9syQxgn4yq57SGWrftX4vm4lXiXx2y4iaECVu8kErJaIVZcchvmfJxXGVeJeFzJHJadS2xSEua3UAOi5v8WTDfWpa(sms8f2WTDXHhsom5SEJgCFNfeoQykgVIbFjgj(YgdhbgyTVy9OaUD1qrYR4HB7IdpSHI8TxIcJZeRchpAVVZ3fnp3Veet8uVhfW1toZtefXZgkY3EjEcZbGtu(oliCuXumEfd(sms8LngocmbXKfRhfWTRgksEfpC7upYtyCun3ehrTfNh1G2gLkQT4aht9XgP4vmBQhDBqqe5yEoypTGWrLNaotykF3uhWzcBo6uNXRyWxIrIVmhDU525Ot9xgn4yZUN6bcxoHBtDO9ulpfEaxEf7PgnEkg4LOycI0wh82lXaQxgn4yE2XZacbWqJlftqK26G3EjgqrEZ4fZZ98ehEgrpJdyEQrJNyirbdS2xSEuaxf5nJxmp3BONXbmp1OXtXaVeLXcVWSkC1lJgCmp74jgsuWaR9fRhfWvrEZ4fZZ98eApdieadnUugl8cZQWvK3mEX8CdpPPGHvgl8cZQWvyuet4OYtO8SJNbecGHgxkJfEHzv4kYBgVyEUNNd2ZoEcTNA5PyGxIIjisBDWBVedOEz0GJ5PgnEkg4LOycI0wh82lXaQxgn4yE2XZacbWqJlftqK26G3EjgqrEZ4fZZ98CloIYtO8ekp74j0EstbdRgZlSvmftumXc465EEUDWEQrJN2(FcxUIhxhrXwqqYlHBafXkC9epd9ehEQrJN0uWWkGfPTyuK4ROG4PgnEQLN0uWWkAacHbOyIIcINq5zhp1YtAkyyfJIe)fcEbbn(effKPUfeoQM6WaR9fRhfWDkZnXXC0P(lJgCSz3t9aHlNWTPUyGxIYyHxywfU6LrdoMND8mGqam04sbSiTfnfHjkYBgVyEIhpJYZoEcTNbecGHgxkMGiT1bV9smGI8MXlMN755wCeLNA04PwEkg4LOycI0wh82lXaQxgn4yEcLND8eAp1YtXaVefpCykc(Qxgn4yEQrJNA5jnfmSIhomfbFffep74PwEgqiagACP4HdtrWxrbXtOM6wq4OAQBSWlmRcFkZnh0C0P(lJgCSz3t9aHlNWTPUyGxI6G3EjgyrdmMOEz0GJ5zhpH2tXaVevZyYjle8s6)6G3Ejm1lJgCmp74jnfmSQzm5KfcEj9FDWBVeMIcIND8SzhWecQ55EEQ9r5PgnEQLNIbEjQMXKtwi4L0)1bV9syQxgn4yEcLND8eAp1YtO9KjisBDWBVedOOG4zhpfd8sumbrARdE7Lya1lJgCmpHYtnA802)t4YvLjuedS6nsdv4RiwHRNd9CqE2XtAkyy1yEHTIPyIIjwaxp3ZZTd2tOM6wq4OAQFWBVedSObgtMYCZbphDQ)YObhB29upq4YjCBQlg4LOycI0W9hYjQxgn4yE2XtO9KyCS1J8LOmmmMkGOkXZ98CqEQrJNeJJTEKVeLHHXu8Yt84P2IYtO8SJNq7PwEkg4LOyuK4VqWliOXNOEz0GJ5PgnEstbdRyuK4VqWliOXNOOG4PgnE2Sdycb18epd9CWd2tOM6wq4OAQZeePH7pKtMYCtTnhDQ)YObhB29upq4YjCBQlg4LOaCTdfhB1S4MTeK8M6LrdoMND8eApjghB9iFjkddJPciQs8CpphKNA04jX4yRh5lrzyymfV8epEQTO8eQPUfeoQM6aU2HIJTAwCZwcsEBkZn1(5Ot9xgn4yZUN6bcxoHBtDAkyyftqKgU)qorrbXZoEYGCayjgj(ctf6nETa84EP4vSN75jo8SJNq7jnfmSQzm5KfcEj9FDWBVeMIcIND8ulpfd8sumks8xi4fe04tuVmAWX8uJgpPPGHvmks8xi4fe04tuuq8eQPUfeoQM6aECVu8kErJaYuMBIxohDQ)YObhB29upq4YjCBQZGCayjgj(ctf6nETa84EP4vSN4XZTE2XtO9ulpfd8sumks8xi4fe04tuVmAWX8uJgp1YtmKOGbw7lwpkGRICyYz9gn4EQrJNmbrARdE7LyaffepHYZoEcTNA5PyGxIQzm5KfcEj9FDWBVeM6LrdoMNA04jnfmSQzm5KfcEj9FDWBVeMIcINA04zZoGjeuZt8m0tCoo8eQPUfeoQM63isV2HYW9tzU5(Eo6u)Lrdo2S7PEGWLt42uxlpPPGHvmks8xi4fe04tuuq8SJNIbEjQMXKtwi4L0)1bV9syQxgn4yE2XtO9KMcgw1mMCYcbVK(Vo4TxctrbXtnA8mGqam04sbSiTfnfHjkYBgVyEIhpJYZoE2Sdycb18epd9eNJdp3WZbfLNr0tXaVevWaGL0)L0tvyNOEz0GJ5PgnEstbdRycI0W9hYjkkiE2XZacbWqJlfWI0w0ueMOiVz8I55Ed9moG5jutDliCun1VrK(fRhfWDkZnX5ZrN6VmAWXMDp1deUCc3M6A5PyGxIQzm5KfcEj9FDWBVeM6LrdoMND8ulpH2tB)pHlxXJRJOylii5LWnGIyfUEIhpXHND8KMcgwzSWlmRcxrbXtO8SJNq7jnfmSIjisd3FiNOOG4PgnE2Sdycb18epd9eNhLNB45GIYZi6PyGxIkyaWs6)s6PkStuVmAWX8uJgp1YtO9KjisBDWBVedOOG4zhpfd8sumbrARdE7Lya1lJgCmpHYZoEECcYdYXwbuJ2Kf4vS075aEk829CapdieadnUumbrARdE7Lyaf5nJxmphWZTAlkpJONWaeI4j0EcTNhNG8GCSva1OnzbEfl9EoGNcVDphWZacbWqJlftqK26G3EjgqrEZ4fZtO8eV55wTfLNq5jEg65GIYZi6j0EU1Zn8eApT9)eUC1d9OfcEj9FDWBVedWueRW1t8m0tC4juEcLNqn1TGWr1u)gr6xSEua3Pm3CBuZrN6VmAWXMDp1deUCc3M6IbEjkgfj(le8ccA8jQxgn4yE2XtT8KMcgwXOiXFHGxqqJprrbXZoEgqiagACPawK2IMIWef5nJxmp3BONXbmp74j0EQLNIbEjkMGiT1bV9smG6LrdoMND8ulpH5KVo4TxIbuuq8uJgpfd8sumbrARdE7Lya1lJgCmp74PwEYeePTo4TxIbuuq8eQPUfeoQM63is)I1Jc4oL5MB3ohDQ)YObhB29upq4YjCBQZeePTo4TxIbuuq8SJNIbEjkMGiT1bV9smG6LrdoMND8eApT9)eUCfpUoIITGGKxc3akIv465EEIdp1OXtT8KMcgwbSiTfJIeFffep74jnfmSIgGqyakMOOG4jutDliCun1b84EP4v8IgbKPm3CloMJo1Fz0GJn7EQhiC5eUn1fd8su8WHPi4REz0GJ5zhpfd8sunJjNSqWlP)RdE7LWuVmAWX8SJN0uWWkE4Wue8vuq8SJN0uWWQMXKtwi4L0)1bV9sykkitDliCun1HjiMSy9OaUtzU52bnhDQ)YObhB29upq4YjCBQttbdRmw4fMvHROGm1TGWr1uhyrAlAkctMYCZTdEo6u)Lrdo2S7PUfeoQM6WaR9fRhfWDQhiC5eUn1jhMCwVrdUND80ccpYVE9g)mpXJNB9SJN0uWWkgfj(le8ccA8jkkit9a(bWxIrIVWMBUDkZn3QT5Ot9xgn4yZUN6bcxoHBtDXaVeftqK26G3Ejgq9YObhZZoEgqiagACTi3cIND8KMcgwXOiXFHGxqqJprrbXZoEcTNhNG8GCSva1OnzbEfl9EoGNcVDphWZacbWqJlftqK26G3EjgqrEZ4fZZb8CR2IYZi6jmaHiEcTNq75XjipihBfqnAtwGxXsVNd4PWB3Zb8mGqam04sXeePTo4TxIbuK3mEX8ekpXBEUvBr5juEUNNdkkpJONq75wp3WtO902)t4Yvp0Jwi4L0)1bV9smatrScxpXZqpXHNq5juEQrJNq75w1wT3Zi6j0EECcYdYXwbuJ2Kf4vS075aEk829ekphWZacbWqJlftqK26G3EjgqrEZ4fZZb8CR2IYZi6jmaHiEcTNq75w1wT3Zi6j0EECcYdYXwbuJ2Kf4vS075aEk829ekphWZacbWqJlftqK26G3EjgqrEZ4fZtO8eV55wTfLNq5juEUNNq75XjipihBfqnAtwGxXsVNd4PWB3Zb8mGqam04sXeePTo4TxIbuK3mEX8Cap3QTO8mIEcdqiINq7j0EECcYdYXwbuJ2Kf4vS075aEk829CapdieadnUumbrARdE7Lyaf5nJxmpHYt8MNB1wuEcLNq5jutDliCun1bwK2IMIWKPm3CR2phDQ)YObhB29upq4YjCBQRLNIbEjkMGiT1bV9smG6LrdoMND8mGqam04ArUfep74jnfmSIrrI)cbVGGgFIIcIND8eAppob5b5yRaQrBYc8kw69CapfE7EoGNbecGHgxkyo5RdE7Lyaf5nJxmphWZTAlkpJONWaeI4j0EcTNhNG8GCSva1OnzbEfl9EoGNcVDphWZacbWqJlfmN81bV9smGI8MXlMNq5jEZZTAlkpHYZ98Cqr5ze9eAp365gEcTN2(FcxU6HE0cbVK(Vo4TxIbykIv46jEg6jo8ekpHYtnA8eAp3Q2Q9EgrpH2ZJtqEqo2kGA0MSaVILEphWtH3UNq55aEgqiagACPG5KVo4TxIbuK3mEX8Cap3QTO8mIEcdqiINq7j0EUvTv79mIEcTNhNG8GCSva1OnzbEfl9EoGNcVDpHYZb8mGqam04sbZjFDWBVedOiVz8I5juEI38CR2IYtO8ekp3ZtO984eKhKJTcOgTjlWRyP3Zb8u4T75aEgqiagACPG5KVo4TxIbuK3mEX8Cap3QTO8mIEcdqiINq7j0EECcYdYXwbuJ2Kf4vS075aEk829CapdieadnUuWCYxh82lXakYBgVyEcLN4np3QTO8ekpHYtOM6wq4OAQdSiTfnfHjtzU5w8Y5Ot9xgn4yZUN6bcxoHBtDAkyyfJIe)fcEbbn(effKPUfeoQM6aECVu8kErJaYuMBUDFphDQ)YObhB29upq4YjCBQhqiagACTi3cIND8ulpfd8sunJjNSqWlP)RdE7LWuVmAWXM6wq4OAQdSiTfnfHjtzU5wC(C0P(lJgCSz3t9aHlNWTPUyGxIIhomfbF1lJgCmp74PwEcTNn7aMqqnpXJN4LAZZoEgqiagACPawK2IMIWef5nJxmp3BONr5juE2XtO9ulpfd8sumbrARdE7Lya1lJgCmp1OXZacbWqJlftqK26G3EjgqrEZ4fZZ98CloIYtOM6wq4OAQZdhMIG)uMBIJOMJo1Fz0GJn7EQhiC5eUn1dieadnUwKBbXZoEg6ns8zEIhpfd8sup0Jwi4L0)1bV9syQxgn4ytDliCun1bwK2IMIWKPm3ehBNJo1Fz0GJn7EQhiC5eUn1fd8su8WHPi4REz0GJ5zhpPPGHv8WHPi4ROG4zhpPPGHv8WHPi4RiVz8I55EEUvT1Zi6zCaZZi6jnfmSIhomfbFftSaUtDliCun1HjiMSy9OaUtzUjoWXC0P(lJgCSz3t9aHlNWTPEaHayOX1IClitDliCun1bwK2IMIWKPm3ehdAo6u)Lrdo2S7PUfeoQM6WaR9fRhfWDQhiC5eUn1jhMCwVrdUND8ulpPPGHvmks8xi4fe04tuuqM6b8dGVeJeFHn3C7uMBIJbphDQ)YObhB29upq4YjCBQlg4LOeK82Qzm5e8vVmAWX8SJNq7jnfmSICgQSk8LGK3uK3mEX8Cpp1Ep1OXtO9KMcgwrodvwf(sqYBkYBgVyEUNNq7jnfmSYyHxywfUcJIychvEUHNbecGHgxkJfEHzv4kYBgVyEcLND8mGqam04szSWlmRcxrEZ4fZZ98CR28ekpHAQBbHJQPUGK3wnJjNG)uMBIdTnhDQ)YObhB29upq4YjCBQlg4LO4HdtrWx9YObhZZoEstbdR4HdtrWxrbXZoEcTN0uWWkE4Wue8vK3mEX8CppJdyEgrphSNr0tAkyyfpCykc(kMybC9uJgpPPGHvmbrA4(d5effep1OXtT8umWlr1mMCYcbVK(Vo4Txct9YObhZtOM6wq4OAQdtqmzX6rbCNYCtCO9ZrN6wq4OAQd4X9sXR4fncit9xgn4yZUNYCtCGxohDQ)YObhB29u3cchvtDyG1(I1Jc4o1d4haFjgj(cBU52PEGWLt42uNCyYz9gn4t9gksEfp13oL5M4yFphDQ)YObhB29upq4YjCBQ3qr(2lrHXzIvH7jE8u7N6wq4OAQddS2xSEua3PEdfjVIN6BNYCtCGZNJo1BOi5v8uF7u3cchvtDycIjlwpkG7u)Lrdo2S7PmLPUH(C05MBNJo1Fz0GJn7EQhiC5eUn1fd8sumbrA4(d5e1lJgCSPUfeoQM6mbrA4(d5KPm3ehZrN6VmAWXMDp1TGWr1uhgyTVy9OaUt9aHlNWTPo5WKZ6nAW9SJNq7jdYbGLyK4lmvO341cWJ7LIxXEUNNq7P28Cap1YtXaVeLGK3wnJjNGV6LrdoMNq5PgnEQLNIbEjkMGiT1bV9smG6LrdoMND8eApH5KVo4TxIbuK3mEX8epEcTNBhSNr0tgKdaREJj3tO8uJgpdieadnUuWCYxh82lXakYBgVyEUNNq7jogSNd452b7ze9Kb5aWQ3yY9ekpHYtO8SJNq7PwEkg4LOycI0wh82lXaQxgn4yEQrJNmbrARdE7LyafgAC5PgnEYGCayjgj(ctf6nETa84EP4vSNd9CqE2XtAkyy1yEHTIPyIIjwaxp3ZZTd2tOM6b8dGVeJeFHn3C7uMBoO5Ot9xgn4yZUN6bcxoHBtDXaVeLXcVWSkC1lJgCmp74j0Ekg4LOycI0wh82lXaQxgn4yE2XtMGiT1bV9smGcdnU8SJNbecGHgxkMGiT1bV9smGI8MXlMN4XZTAZtnA8ulpfd8sumbrARdE7Lya1lJgCmpHYZoEcTNA5PyGxIIhomfbF1lJgCmp1OXtT8KMcgwXdhMIGVIcIND8ulpdieadnUu8WHPi4ROG4jutDliCun1nw4fMvHpL5MdEo6u)Lrdo2S7PEGWLt42uxmWlrb4Ahko2QzXnBji5n1lJgCSPUfeoQM6aU2HIJTAwCZwcsEBkZn12C0P(lJgCSz3t9aHlNWTPUwEkg4LOAgtozHGxs)xh82lHPEz0GJ5PgnEstbdRycI0W9hYjkkiEQrJNn7aMqqnpXZqpH2ZTrfLNd45G9mIEYGCayjgj(ctf6nETa84EP4vSNq5PgnEstbdRAgtozHGxs)xh82lHPOG4PgnEYGCayjgj(ctf6nETa84EP4vSN4XZbn1TGWr1u)gr61ougUFkZn1(5Ot9xgn4yZUN6bcxoHBtDAkyyftqKgU)qorrEZ4fZZ98CqEgrpJdyEgrpPPGHvmbrA4(d5eftSaUtDliCun1d9gVwaECVu8kEkZnXlNJo1Fz0GJn7EQhiC5eUn1PPGHvalsBXOiXxrbXZoEYGCayjgj(ctf6nETa84EP4vSN755G9SJNq7PwEkg4LOycI0wh82lXaQxgn4yEQrJNmbrARdE7LyafgAC5juE2XtmKOGbw7lwpkGRs4bC5v8u3cchvtDGfPTOPimzkZn33ZrN6VmAWXMDp1deUCc3M6mihawIrIVWuHEJxlapUxkEf75EEoyp74PwEstbdRmw4fMvHROGm1TGWr1uNhomfb)Pm3eNphDQ)YObhB29upq4YjCBQZGCayjgj(ctf6nETa84EP4vSN755G9SJN0uWWkE4Wue8vuq8SJNA5jnfmSYyHxywfUIcYu3cchvtDycIjlwpkG7uMBUnQ5Ot9xgn4yZUN6bcxoHBtDXaVe1bV9smWIgymr9YObhZZoEYGCayjgj(ctf6nETa84EP4vSN755G9SJNq7PwEkg4LOycI0wh82lXaQxgn4yEQrJNmbrARdE7LyafgAC5jutDliCun1p4TxIbw0aJjtzU52TZrN6VmAWXMDp1deUCc3M6IbEjkJfEHzv4Qxgn4ytDliCun1bwK2I(wBkZn3IJ5OtDliCun1d9gVwaECVu8kEQ)YObhB29uMBUDqZrN6VmAWXMDp1deUCc3M6IbEjkJfEHzv4Qxgn4ytDliCun1bwK2IMIWKPEdfjVIN6BNYCZTdEo6u)Lrdo2S7PUfeoQM6WaR9fRhfWDQhWpa(sms8f2CZTt9aHlNWTPo5WKZ6nAWN6nuK8kEQVDkZn3QT5Ot9gksEfp13o1TGWr1uhMGyYI1Jc4o1Fz0GJn7EktzQJDyJciZrNBUDo6u)Lrdo2KEQhiC5eUn1T9)eUCLvHZeIbwKZqLvHREz0GJn1TGWr1uNgGqyakMmL5M4yo6u)Lrdo2S7PEGWLt42u)4eKhKJTcOgTjlWRyP3Zb8u4T75EEoOO8uJgpH5KVo4TxIbuuq8uJgpzcI0wh82lXakkitDliCun1HGeoQMYCZbnhDQBbHJQP(yEHTy93it9xgn4yZUNYCZbphDQ)YObhB29upq4YjCBQlg4LOeK82Qzm5e8vVmAWX8SJN0uWWkYzOYQWxcsEtrEZ4fZZ98ehtDliCun1fK82Qzm5e8NYCtTnhDQ)YObhB29upq4YjCBQRLNIbEjkMGiT1bV9smG6Lrdo2u3cchvtDyo5RdE7LyGPm3u7NJo1Fz0GJn7EQhiC5eUn1fd8sumbrARdE7Lya1lJgCmp74j0EQLNIbEjkE4Wue8vVmAWX8uJgp1YtAkyyfpCykc(kkiE2XtT8mGqam04sXdhMIGVIcINq5zhpH2tT8umWlrzSWlmRcx9YObhZtnA8ulpdieadnUugl8cZQWvuq8SJNA5jnfmSYyHxywfUIcINqn1TGWr1uNjisBDWBVedmL5M4LZrN6wq4OAQtX(IlVXM6VmAWXMDpL5M775Ot9xgn4yZUN6bcxoHBtDT8umWlrzSWlmRcx9YObhZtnA8KMcgwzSWlmRcxrbXtnA8mGqam04szSWlmRcxrEZ4fZt84P2IAQBbHJQPonaHWwWue8NYCtC(C0P(lJgCSz3t9aHlNWTPUwEkg4LOmw4fMvHREz0GJ5PgnEstbdRmw4fMvHROGm1TGWr1uN(e2j4YR4Pm3CBuZrN6VmAWXMDp1deUCc3M6A5PyGxIYyHxywfU6LrdoMNA04jnfmSYyHxywfUIcINA04zaHayOXLYyHxywfUI8MXlMN4XtTf1u3cchvtDyo50aecBkZn3UDo6u)Lrdo2S7PEGWLt42uxlpfd8sugl8cZQWvVmAWX8uJgpPPGHvgl8cZQWvuq8uJgpdieadnUugl8cZQWvK3mEX8epEQTOM6wq4OAQBv4mHyGvWaGPm3CloMJo1Fz0GJn7EQhiC5eUn1zcI0wh82lXakkiE2XtAkyyvWaGfGh3lfVIvK3mEX8epd9CFp1TGWr1u)4)fcEj9FXeePnL5MBh0C0PUfeoQM6TlhrM6VmAWXMDpL5MBh8C0P(lJgCSz3t9aHlNWTPUfeEKF96n(zEIhpXHND8eApzqoaSeJeFHPc9gVwaECVu8k2t84jo8uJgpzqoaSeJeFHPawK2I(wZt84jo8eQPUfeoQM6eQAzbHJQfGZKPoGZKvzTp1n0NYCZTABo6u)Lrdo2S7PUfeoQM6eQAzbHJQfGZKPoGZKvzTp1z8kg8LyK4ltzktDiKhqnAtMJo3C7C0P(lJgCSz3tzUjoMJo1Fz0GJn7EkZnh0C0P(lJgCSz3tzU5GNJo1Fz0GJn7EkZn12C0PUfeoQM6csEB1mMCc(t9xgn4yZUNYCtTFo6u)Lrdo2S7PEGWLt42uxlpfd8suqi8Mbwh82lXaCMOEz0GJn1TGWr1u)gr6xh82lXatzUjE5C0P(lJgCSz3t9aHlNWTPUyGxIIjisd3FiNOEz0GJ5zhpH2tIXXwpYxIYWWyQaIQep3ZZb5PgnEsmo26r(sugggtXlpXJNAlkpHAQBbHJQPotqKgU)qozkZn33ZrN6VmAWXMDp1deUCc3M6A5PyGxIIjisBDWBVedOEz0GJn1TGWr1uhMt(6G3EjgykZnX5ZrN6VmAWXMDp1deUCc3M6IbEjkMGiT1bV9smG6Lrdo2u3cchvtDMGiT1bV9smWuMBUnQ5OtDliCun1HGeoQM6VmAWXMDpL5MB3ohDQ)YObhB29upq4YjCBQlg4LOo4TxIbw0aJjQxgn4ytDliCun1p4TxIbw0aJjtzU5wCmhDQ)YObhB29upq4YjCBQRLNIbEjQdE7LyGfnWyI6LrdoMND8Kb5aWsms8fMk0B8Ab4X9sXRyp3ZZbn1TGWr1uhyrAlAkctMYCZTdAo6u)Lrdo2S7PEGWLt42uNb5aWsms8fMk0B8Ab4X9sXRypXJN4yQBbHJQPEO341cWJ7LIxXtzktzQBuspIm115nkGjCuPDtmyzktzob]] )


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
