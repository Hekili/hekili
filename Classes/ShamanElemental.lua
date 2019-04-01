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


    spec:RegisterPack( "Elemental", 20190401.1440, [[devAYbqiHWJKsXLifKnjL8jsHQrbsDkOIvbvPxPu0SesDlfu7IKFPuyykihdKSmOs9mHettkLUMqKTjeLVrkumosb05GkH1Pus17ifkH5bcDpfyFqv8pLsKQdkevTqPu9qLsutuPe6IcjTrsb4JkLuAKkLiLtQucwji6LKcLAMkLKBcvI2ji4NkLigkPaTuLskEkPAQkL6QcrLVQuIKXskusNLuOeTxL8xfnyrhMYIrQhlyYq5YQ2mO(SqnAP40O8AfYSbUTuTBj)gYWvQooPGA5iEoQMoX1rY2HQ67kuJhQKopPO1tkK5tkTFQEb1A7LoMjFbbCpeu4IHA7qqPGQTTDOH0ax6IM7FPVBHrw8x6L1)spQG3FjgyPVBAcqg2A7LohrrcFP3iYoFRVXgXmPHIwfq9n4SofWegQcedw2GZ6Hnw60umGSfQf9shZKVGaUhckCXqTDiOuq12OGlI0sNV)Wcc4oYW9sVHHH9ArV0XopS0BJNrf8(lXaEQ3yDRCiBJNnISZ36BSrmtAOOvbuFdoRtbmHHQaXGLn4SEydhY24zKFNWaEcv0EI7HGcx45WEoeUyRJBC7q6q2gp3YnwfF(w3HSnEoSNro(9uJ15bV)smGIA3tIjnN4P0yLNHMhgXQypdieadnU4Ekip5)EYG98G3FjgG7PrUNwqy4FLdzB8Cyp3ImUrdoMNr1isJNrf8(lXaE(siSZvoKTXZH9CR5De(3Zipp8cZQW9uy9Vr7BLNHMhgPCiBJNd7zKhdZZOQ59eb7P0Cp1feP75gEIlVCerT03jiyg4l924zubV)smGN6nw3khY24zJi78T(gBeZKgkAva13GZ6uatyOkqmyzdoRh2WHSnEg53jmGNqfTN4EiOWfEoSNdHl264g3oKoKTXZTCJvXNV1DiBJNd7zKJFp1yDEW7VedOO29KysZjEknw5zO5HrSk2ZacbWqJlUNcYt(VNmypp49xIb4EAK7Pfeg(x5q2gph2ZTiJB0GJ5zunI04zubV)smGNVec7CLdzB8Cyp3AEhH)9mYZdVWSkCpfw)B0(w5zO5HrkhY245WEg5XW8mQAEprWEkn3tDbr6EUHN4YlhruoKoKTXZOIRpqjhZt6dJi3ZaQtBIN0pMvCLNr(q47c3Zcvd3yKomfWtlimuX9evanvoKwqyOIR2jpG60Mmagy8roKwqyOIR2jpG60MS5GnGrimhslimuXv7KhqDAt2CWggvC)LycdvoKoKTXt9Y25niXtIXW8KMcg(yEYft4EsFye5EgqDAt8K(XSI7PvyEUt(W7iryvSNmUNyO6khslimuXv7KhqDAt2CWg8Y25nizYft4oKwqyOIR2jpG60MS5GneK8(SBC5enDiTGWqfxTtEa1PnzZbBCJinZdE)LyGOzWdIqmWlrTtyDdmp49xIbyCr9YObhZH0HSnEg543tDbr6J(3pXZDYdOoTjEsvGZ5EYr97PHHX9Cmda8KVBJlp5iuPCiTGWqfxTtEa1PnzZbBWfePp6F)KOzWded8suCbr6J(3pr9YObhRf0eJHnp(VeLHHXvbevjqmkA1smg284)sugggxXk8ePHWXH0H0ccdvC1o5buN2KnhSbmJ85bV)smq0m4brig4LO4cI0Nh8(lXaQxgn4yoKwqyOIR2jpG60MS5Gn4cI0Nh8(lXarZGhig4LO4cI0Nh8(lXaQxgn4yoKwqyOIR2jpG60MS5Gn2rcdvoKwqyOIR2jpG60MS5Gno49xIbM0aJlrZGhig4LOo49xIbM0aJlQxgn4yoKwqyOIR2jpG60MS5Gnag(2KMIWLOzWdIqmWlrDW7VedmPbgxuVmAWXAX3pamfJeFHRcngRMawCJuSkgIrXH0ccdvC1o5buN2KnhSrOXy1eWIBKIvXrZGhW3pamfJeFHRcngRMawCJuSkgp42H0HSnEgvC9bk5yEE8prtpfw)Ekn3tliiINmUNg(gdy0GRCiBJNBzJlE2oaHWauCXZUvugaOPNmypLM7zKxJoHj3ZTjgt8mYxHZfIb8CR5Cuzv4EY4EUto)LOCiTGWqfFanaHWauCjAg8atJoHjxzv4CHyGj5Cuzv4Qxgn4yoKoKTXZTqnCa1PnXZDKWqLNmUN7KdFYlHzaGMEcy1OJ5PG8utefXZOcE)LyGO9KQaNZ9mG60M45yga45lmp5niIa00H0ccdv8nhSXosyOkAg8GJR7pihBgqDAtMGxXsZWcRFigLH0QfMr(8G3FjgqrTRvlxqK(8G3FjgqrT7q6q2gp3cLCcHAx8eb7zW4cx5qAbHHk(Md2ymRWM8MBehshslimuX3CWgcsEF2nUCIMrZGhig4LOeK8(SBC5envVmAWXArtbdRiNJkRcFki5Df5DJvCiIBhslimuX3CWgWmYNh8(lXarZGheHyGxIIlisFEW7VedOEz0GJ5qAbHHk(Md2GlisFEW7VedendEGyGxIIlisFEW7VedOEz0GJ1c6ied8suSWHPiAQEz0GJPvBe0uWWkw4Wuenvu7TIiGqam04sXchMIOPIAhNwqhHyGxIY4HxywfU6LrdoMwTreqiagACPmE4fMvHRO2XXHSnEAbHHk(Md24grAMh8(lXarZGheHyGxIANW6gyEW7VedW4I6LrdoMwTIbEjQDcRBG5bV)smaJlQxgn4yTGgMr(8G3FjgqHHgxTIqmWlrXfePpp49xIbuVmAWX0QLlisFEW7VedOWqJRwIbEjkUGi95bV)smG6LrdogooKwqyOIV5GnO4FYK35oKwqyOIV5GnObie2eMIOz0m4brig4LOmE4fMvHREz0GJPvlnfmSY4HxywfUIAxR2acbWqJlLXdVWSkCf5DJvC8ePHCiTGWqfFZbBqFc)KrSkoAg8Gied8sugp8cZQWvVmAWX0QLMcgwz8WlmRcxrT7qAbHHk(Md2aMronaHWIMbpicXaVeLXdVWSkC1lJgCmTAPPGHvgp8cZQWvu7A1gqiagACPmE4fMvHRiVBSIJNinKdPfegQ4BoydRcNledmdgaendEqeIbEjkJhEHzv4Qxgn4yA1stbdRmE4fMvHRO21QnGqam04sz8WlmRcxrE3yfhprAihslimuX3CWgxZprWtP5tUGi9OzWd4cI0Nh8(lXakQ9w0uWWQGbatalUrkwfRiVBSIJNbAGoKwqyOIV5Gn6xoI4qAbHHk(Md2GqvtlimunbmUeDz9pWqpAg8alim8)817SZXdUBbnF)aWums8fUk0ySAcyXnsXQy8GBTA57haMIrIVWvadFBsFRJhCJJdPfegQ4BoydcvnTGWq1eW4s0L1)aoRIbFkgj(IdPdzB8exsbeMNIrIV4PfegQ8CNWqeMOPNagxCiTGWqfxzOpGlisF0)(jrZGhig4LO4cI0h9VFI6LrdoMdPdzB8uFNCdZtnaG1VN6nOWipzLNqCGNT1tXiXx8eMf3i8O9KMs8SqINyuewf7PEu9KAxy9hnvboN7PMikno5EcZIBewf7zu8ums8fUNwH5zJH)9eCo3tPXkpHQTEULIvyEU1sXfp5IfgXvoKwqyOIRm03CWgWaR)jVbfgfDqZa4tXiXx4dGkAg8aYHjN3y0G3cA((bGPyK4lCvOXy1eWIBKIvXqe6inCeIbEjkbjVp7gxort1lJgCmC0QncXaVefxqK(8G3Fjgq9YObhRf0WmYNh8(lXakY7gR44bAOAlE57haMngxooA1gqiagACPGzKpp49xIbuK3nwXHi04UTddvBXlF)aWSX4YXbhCAbDeIbEjkUGi95bV)smG6LrdoMwTCbr6ZdE)LyafgACPvlF)aWums8fUk0ySAcyXnsXQ4brPfnfmSAmRWMXuCrXflmcIq1wCCiTGWqfxzOV5GnmE4fMvHhndEGyGxIY4HxywfU6LrdowlOfd8suCbr6ZdE)Lya1lJgCSwCbr6ZdE)LyafgAC1kGqam04sXfePpp49xIbuK3nwXXdursR2ied8suCbr6ZdE)Lya1lJgCmCAbDeIbEjkw4WuenvVmAWX0QncAkyyflCykIMkQ9wreqiagACPyHdtr0urTJJdPfegQ4kd9nhSbGPHPyyZUf3TPGK3JMbpqmWlrbyAykg2SBXDBki5D1lJgCmhshY2452en9uqEgB97zunI0OHPSr3ZXmPXtCPXLt8eb7P0CpJk49xc3tAkyyph38YtywCJWQypJINIrIVWvEUfrLgx8eH)jbB3tCPDaxiOEeoKwqyOIRm03CWg3isJgMYg9OzWdIqmWlr1nUCYebpLMpp49xcx9YObhtRwAkyyfxqK(O)9tuu7A12Td4cb1XZaOHAOHgUT4LVFaykgj(cxfAmwnbS4gPyvmoA1stbdR6gxozIGNsZNh8(lHRO21QLVFaykgj(cxfAmwnbS4gPyvmEIIdPdzB8exAJUNCkY9uteLNyOsJlEcq87P5PUGi9r)7NOCiTGWqfxzOV5GncngRMawCJuSkoAg8aAkyyfxqK(O)9tuK3nwXHyuWBCadV0uWWkUGi9r)7NO4Ifg5q6q2gp3skGMEgmU45wz4BE2ofHlEIkpLgYVNIrIVW9Kb7jt8KX90kpzfxSs80kmp1feP7zubV)smGNmUNqylzBpTGWW)khslimuXvg6BoydGHVnPPiCjAg8aAkyyfWW3MCks8vu7T47haMIrIVWvHgJvtalUrkwfdX22c6ied8suCbr6ZdE)Lya1lJgCmTA5cI0Nh8(lXakm04cNwyirbdS(N8guyKsyHrSk2H0ccdvCLH(Md2GfomfrZOzWd47haMIrIVWvHgJvtalUrkwfdX22kcAkyyLXdVWSkCf1UdPfegQ4kd9nhSbmbXLjVbfgfndEaF)aWums8fUk0ySAcyXnsXQyi22w0uWWkw4Wuenvu7TIGMcgwz8WlmRcxrT7q6q2gpJC87zubV)smGNTdmU4PfBSIlEsT7PG8mkEkgj(c3tJ7javXEACp1feP7zubV)smGNmUNfs80ccd)RCiTGWqfxzOV5Gno49xIbM0aJlrZGhig4LOo49xIbM0aJlQxgn4yT47haMIrIVWvHgJvtalUrkwfdX22c6ied8suCbr6ZdE)Lya1lJgCmTA5cI0Nh8(lXakm04chhslimuXvg6BoydGHVnPV1JMbpqmWlrz8WlmRcx9YObhZH0ccdvCLH(Md2i0ySAcyXnsXQyhslimuXvg6BoydGHVnPPiCj6ocFwfpaQOzWded8sugp8cZQWvVmAWXCiTGWqfxzOV5GnGbw)tEdkmk6ocFwfpaQOdAgaFkgj(cFaurZGhqom58gJgChslimuXvg6BoydycIltEdkmk6ocFwfpakhshY24PoRIb3ZTns8fpJ8bHHkp1GegIWen9CRyCXHSnEg1ItrUNAa6EY4EAbHH)9KQaNZ9uteLNng(3tOARNiINDe5EYflmI7jc2ZTuScZZTwkU4jmb19uxqKUNrf8(lXakpHoQyX3ZGX)w3tQ9aQZQypJ88GN0uINwqy4Fp1JQgl8edvACXtCCiTGWqfxXzvm4tXiXxgadS(N8guyu0m4bqhHWcJyvSwTIbEjkUGi95bV)smG6LrdowRacbWqJlfxqK(8G3FjgqrE3yfhI4gVXbmTAXqIcgy9p5nOWif5DJvCioioGPvRyGxIY4HxywfU6LrdowlmKOGbw)tEdkmsrE3yfhIqhqiagACPmE4fMvHRiVBSIVjnfmSY4HxywfUcJIycdv40kGqam04sz8WlmRcxrE3yfhITTf0rig4LO4cI0Nh8(lXaQxgn4yA1kg4LO4cI0Nh8(lXaQxgn4yT4cI0Nh8(lXakm04chCAbnnfmSAmRWMXuCrXflmcIq1wTAnn6eMCflUoIIp3rYlHzafXQr4zaU1QLMcgwbm8TjNIeFf1UwTrqtbdRObiegGIlkQDCAfbnfmSItrI)ebp3rJprrT7q6q2gpJC87zKNhEHzv4EAWYjEQjIsJJ)9KV)s80aap3kdFZZ2PiCXZqJrIp3tRW8evan9Kb7zDM0CIN6cI09mQG3FjgWZcr8CleomfrtpnY9mqriVeGMEAbHH)voKwqyOIR4Skg8PyK4lBoydJhEHzv4rZGhig4LOmE4fMvHREz0GJ1kGqam04sbm8TjnfHlkY7gR44zOwqZfePpp49xIbuyOXLwTrig4LO4cI0Nh8(lXaQxgn4y40c6ied8suSWHPiAQEz0GJPvBe0uWWkw4Wuenvu7TIiGqam04sXchMIOPIAhhhshY245wevACXtk(9mQG3FjgWZ2bgx8Kb7PMikpdikaMNbJlEAEIlnUCINiypLM7zubV)s4E((oA8jhZZOAePXt9guyKNSIl3WuEUfrLgx8myCXZOcE)LyapBhyCXtmkcRI9uxqKUNrf8(lXaEsvGZ5EQjIYZgd)7zuWvpHGjued45wAgPJknvE2oL4jR8uAyCpdg)EYf0UNuCwf7zubV)smGNTdmU4jQc3tnruEsUfA8eQ26jxSWiUNiyp3sXkmp3AP4IYH0ccdvCfNvXGpfJeFzZbBCW7VedmPbgxIMbpqmWlrDW7VedmPbgxuVmAWXAbTyGxIQBC5KjcEknFEW7VeU6LrdowlAkyyv34Yjte8uA(8G3FjCf1ERUDaxiOoeJSH0QncXaVev34Yjte8uA(8G3FjC1lJgCmCAbDeqZfePpp49xIbuu7Ted8suCbr6ZdE)Lya1lJgCmC0Q10OtyYvLjuedmBmshvAQiwnAquArtbdRgZkSzmfxuCXcJGiuTfhhshY24Pg7)Dp11y7jmI4jWiX3teXtocvEAyyEo2W)CLNrUcCo3tnruE2y4Fp1PiX3teSNAq04tI2tw554gwOXZGXVNAIO8CSvINcYtmefn4Estbd75wXIBKIvXE2ociEsRPN7ieGvXEIlTd4cb19K(WiYBSct5zuXvRVdUN8RHPEf(w3tOgAiCPE0Egv9O9uxJD0EUvThTNBf(ThTNrvpAp3Q2DiTGWqfxXzvm4tXiXx2CWgCbr6J(3pjAg8aXaVefxqK(O)9tuVmAWXAbnXyyZJ)lrzyyCvarvceJIwTeJHnp(VeLHHXvScprAiCAbDeIbEjkofj(te8Chn(e1lJgCmTAPPGHvCks8Ni45oA8jkQDTA72bCHG64zqBBlooKoKwqyOIR4Skg8PyK4lBoydatdtXWMDlUBtbjVhndEGyGxIcW0WumSz3I72uqY7Qxgn4yTGMymS5X)LOmmmUkGOkbIrrRwIXWMh)xIYWW4kwHNineooKoKTXZTmQtZQ7PUGi9r)7N45yM04jU04YjEIG9uAUNrf8(lH7jI4Pofj(EIG9udIgFINuf4CUNAIO8SXW)Ekn3ZTYW38uVbfg5PqmM4PvyE2PacBhCp5IfgXvoKwqyOIR4Skg8PyK4lBoydalUrkwfpPrajAg8aAkyyfxqK(O)9tuu7T47haMIrIVWvHgJvtalUrkwfdrC3cAtJoHjxbm8TjVbfgPiwncV0uWWkGHVn5nOWifxSWiCGiUJSwqttbdR6gxozIGNsZNh8(lHRO2BfHyGxIItrI)ebp3rJpr9YObhtRwAkyyfNIe)jcEUJgFIIAhhhshY24zKJFpJQrKgnmLn6EI)jCkUN42tXiXx4r7jvboN7PMikpBm8VNBLHV5PEdkms5zKJFpJQrKgnmLn6EI)jCkUNq5PyK4lEYG9uteLNng(3ZTFqqfl452nuf2jEgfpfw)CpTcZtiSL4Pofj(EIG9udIgFINVmAWX80kmpHWwINBLHV5PEdkms5qAbHHkUIZQyWNIrIVS5GnUrKgnmLn6rZGhanF)aWums8fUk0ySAcyXnsXQy8aLwTMgDctUsEqqflmLgQc7efXQr4zquAfHyGxIItrI)ebp3rJpr9YObhRLPrNWKRag(2K3GcJueRgbrOWPLPrNWKRag(2K3GcJueRgHxAkyyfWW3M8guyKIlwyeeHokr2MrbVMgDctUsEqqflmLgQc7efXQr4LVFaykgj(cxfAmwnbS4gPyvmoTGocXaVefNIe)jcEUJgFI6LrdoMwTrGHefmW6FYBqHrkYHjN3y0GRvlxqK(8G3FjgqrTJtlOJqmWlr1nUCYebpLMpp49xcx9YObhtRwAkyyv34Yjte8uA(8G3FjCf1UwTbecGHgxkGHVnPPiCrrE3yfhpd1QBhWfcQJNb4cCVzugcVIbEjQGbatP5tPHQWor9YObhdhhshY245w24INr1isJN6nOWiphZKgpXLgxoXteSNsZ9mQG3FjCpfd8s8KMs8SqEAbHH)9uNIeFprWEQbrJpXtAky4O90kmpTGWW)EQlisF0)(jEstbd7PvyEUvg(MNTtr4INbuNvXEIGH9ClVf9CmtAyLNsZ9SoUkEU1UL3Ir7PvyEEM0CINwqy4FpXLgxoXteSNsZ9mQG3FjCpPPGHJ2teXZc5PHVXagn4EUvg(MNTtr4INJByG7zDJ4jUu3ZGThTNiINCwfdUNIrIV4PvyE2PacBhCp3kdFZt9guyKNcXyc3tRW8SBLMEYflmIRCiTGWqfxXzvm4tXiXx2CWg3isZK3GcJIMbpicAkyyfNIe)jcEUJgFIIAVLyGxIQBC5KjcEknFEW7VeU6LrdowlOPPGHvDJlNmrWtP5ZdE)LWvu7A1gqiagACPag(2KMIWff5DJvC8muRUDaxiOoEgGlW9Mrzi8kg4LOcgamLMpLgQc7e1lJgCmTA57haMIrIVWvHgJvtalUrkwfdrC3cAtJoHjxbm8TjVbfgPiwncV0uWWkGHVn5nOWifxSWiiI7idNw0uWWkUGi9r)7NOO2BfqiagACPag(2KMIWff5DJvCioioGHJdPdzB8uJLikphvOXEoUXKT09Cl4zJH5jh1VN8ger8846oWktyOYZMtUNOkCLNTtjEknV8uAUNbuHXegQ8mM8Xr7PvyEUf8SXW8uqEY3bmXtP5EIQ7zunI04PEdkmYtaRUNSsqEcJOikLIJ8uteLNng(3tb5j2nGNJzsJNsdJ7PrJ6SYegQ8SqJ36EULnU4zunI04PEdkmYZXmPbrjEIlnUCINiypLM7zubV)s4Ekg4LeTNwH55yM0GOepBm8zvSNcHTdUNBH46ikUNAqK8sygWtRW80ccd)7zKNhEHzv4r7PvyEAbHH)9uxqK(O)9t8KMcg2teXZ6gXtCPUNbBpAprep1feP7zubV)smGNmUNSYccd)hTNwH5547zWknU45X19hepfKNXx80kpnmmMWqLb8KIFprWEQlis3ZOcE)LyapzLNsZ9K8UXkwf7jmlUr8eMG6EQtrIVNiyp1GOXNOCiTGWqfxXzvm4tXiXx2CWg3isZK3GcJIMbpicXaVev34Yjte8uA(8G3FjC1lJgCSwraTPrNWKRyX1ru85osEjmdOiwncp4UfnfmSY4HxywfUIAhNwqttbdR4cI0h9VFIIAxR2UDaxiOoEgGlgAZOmeEfd8subdaMsZNsdvHDI6LrdoMwTranxqK(8G3FjgqrT3smWlrXfePpp49xIbuVmAWXWP1X19hKJndOoTjtWRyPzyH1)WbecGHgxkUGi95bV)smGI8UXk(WqfPHWlmaHiqd9X19hKJndOoTjtWRyPzyH1)WbecGHgxkUGi95bV)smGI8UXkooAiOI0q4GNbrzi8cnuBcTPrNWKREObnrWtP5ZdE)LyaUIy1i8ma34GdooKoKTXZih)EgvJinEQ3GcJ8Kb7Pofj(EIG9udIgFINmUNIbEjhlApPPepRZKMt8KjEwiINMNBrnOUNrf8(lXaEY4EAbHH)90epLM7zh1Fjr7PvyEUvg(MNTtr4INmUNKByA6jI45yga4j99KCdttphZKgw5P0CpRJRINBTB5TOYH0ccdvCfNvXGpfJeFzZbBCJintEdkmkAg8aXaVefNIe)jcEUJgFI6LrdowRiOPGHvCks8Ni45oA8jkQ9wbecGHgxkGHVnPPiCrrE3yfhIdIdyTGocXaVefxqK(8G3Fjgq9YObhRveWmYNh8(lXakQDTAfd8suCbr6ZdE)Lya1lJgCSwrWfePpp49xIbuu744q6q2gp13TUNBflUrkwf7z7iGW9eJIWQyp1feP7zubV)smGNyuetyOkApzWEQjIYtmuPXfpBm8VNBH46ikUNAqK8sygWteXZgd)7jt8evan9evHhTNwH5jgQ04INu875wXIBKIvXE2ociEIrryvSNTdqimafx8Kb7PMikpBm8VNMNBLHV5Pofj(EQbjOGYH0ccdvCfNvXGpfJeFzZbBayXnsXQ4jncirZGhWfePpp49xIbuu7Ted8suCbr6ZdE)Lya1lJgCSwqBA0jm5kwCDefFUJKxcZakIvJGiU1QncAkyyfWW3MCks8vu7TOPGHv0aecdqXff1oooKoKTXZTSXfp3kwCJuSk2Z2raXtYJncg4CUNiypLM75o54ZquCpdOcJjmu5jd2tnruACmpbi(908uxqK(O)9t8KlwyKNiINng(3tDbr6J(3pXtRW8exAC5eprWEkn3ZOcE)LW90ccd)RCiTGWqfxXzvm4tXiXx2CaGf3ifRIN0iGendEa00uWWkUGi9r)7NOiVBSIdrOuqH34agEPPGHvCbr6J(3prXflmsRwAkyyfxqK(O)9tuu7TOPGHvDJlNmrWtP5ZdE)LWvu744q6q2gpJC87PgabXfp1BqHrEoMjnEUfchMIOPNwH5jU04YjEIG9uAUNrf8(lHRCiTGWqfxXzvm4tXiXx2CWgWeexM8guyu0m4bIbEjkw4WuenvVmAWXAjg4LO6gxozIGNsZNh8(lHREz0GJ1IMcgwXchMIOPIAVfnfmSQBC5KjcEknFEW7VeUIA3H0H0ccdvCfNvXGpfJeFzZbBam8TjnfHlrZGhqtbdRmE4fMvHRO2DiDiBJNroHbyA09uNIeFprWEQbrJpXtb5jFNCdZtnaG1VN6nOWipzWE2PacBhCpF9o7CpnY9CNC(lr5qAbHHkUIZQyWNIrIVS5GnGbw)tEdkmk6GMbWNIrIVWhav0m4bKdtoVXObVLfeg(F(6D254bQw0uWWkofj(te8Chn(ef1UdPdzB8mYXVNBLHV5z7ueU45yM04Pofj(EIG9udIgFINmypLM7jW4IN7i5LWmGNuCl(EIG908uxqKUNrf8(lXaE2y8sJlEAEctbaEIrrmHHkp3s2A8Kb7PMikpdikaMNXx80kK0CINuCl(EIG9uAUNBrnOUNrf8(lXaEYG9uAUNK3nwXQypHzXnINJnUNqfzAipbOk(eLdPfegQ4koRIbFkgj(YMd2ay4BtAkcxIMbpqmWlrXfePpp49xIbuVmAWXAfqiagACnj3cslAkyyfNIe)jcEUJgFIIAVf0hx3Fqo2mG60MmbVILMHfw)dhqiagACP4cI0Nh8(lXakY7gR4ddvKgcVWaeIan0hx3Fqo2mG60MmbVILMHfw)dhqiagACP4cI0Nh8(lXakY7gR44OHGksdHdeJYq4fAO2eAtJoHjx9qdAIGNsZNh8(lXaCfXQr4zaUXbhTAHgkfurgEH(46(dYXMbuN2Kj4vS0mSW6hNHdieadnUuCbr6ZdE)Lyaf5DJv8HHksdHxyacrGgAOuqfz4f6JR7pihBgqDAtMGxXsZWcRFCgoGqam04sXfePpp49xIbuK3nwXXrdbvKgchCGi0hx3Fqo2mG60MmbVILMHfw)dhqiagACP4cI0Nh8(lXakY7gR4ddvKgcVWaeIan0hx3Fqo2mG60MmbVILMHfw)dhqiagACP4cI0Nh8(lXakY7gR44OHGksdHdo44q6q2gpJC875wz4BE2ofHlEoMjnEQtrIVNiyp1GOXN4jd2tP5EcmU45osEjmd4jf3IVNiypnp1ayK7zubV)smGNngV04INMNWuaGNyuetyOYZTKTgpzWEQjIYZaIcG5z8fpTcjnN4jf3IVNiypLM75wudQ7zubV)smGNmypLM7j5DJvSk2tywCJ45yJ7jurMgYtaQIpr5qAbHHkUIZQyWNIrIVS5Gnag(2KMIWLOzWdIqmWlrXfePpp49xIbuVmAWXAfqiagACnj3cslAkyyfNIe)jcEUJgFIIAVf0hx3Fqo2mG60MmbVILMHfw)dhqiagACPGzKpp49xIbuK3nwXhgQineEHbiebAOpUU)GCSza1PnzcEflndlS(hoGqam04sbZiFEW7VedOiVBSIJJgcQineoqmkdHxOHAtOnn6eMC1dnOjcEknFEW7VedWveRgHNb4ghC0QfAOuqfz4f6JR7pihBgqDAtMGxXsZWcRFCgoGqam04sbZiFEW7VedOiVBSIpmurAi8cdqic0qdLcQidVqFCD)b5yZaQtBYe8kwAgwy9JZWbecGHgxkyg5ZdE)Lyaf5DJvCC0qqfPHWbhic9X19hKJndOoTjtWRyPzyH1)WbecGHgxkyg5ZdE)Lyaf5DJv8HHksdHxyacrGg6JR7pihBgqDAtMGxXsZWcR)HdieadnUuWmYNh8(lXakY7gR44OHGksdHdo44q6qAbHHkUIZQyWNIrIVS5GnaS4gPyv8KgbKOzWdOPGHvCks8Ni45oA8jkQDhslimuXvCwfd(ums8LnhSbWW3M0ueUendEqaHayOX1KCliTIqmWlr1nUCYebpLMpp49xcx9YObhZH0tpDiBJN6awCJa00ZyRFp3cHdtr00tAkyypfKNnO9dtbaA6jnfmSNCu)E((oA8jhZtnacIlEQ3GcJ4EoMjnEIlnUCINiypLM7zubV)s4khslimuXvCwfd(ums8LnhSblCykIMrZGhig4LOyHdtr0u9YObhRveq3Td4cb1XJgtKAfqiagACPag(2KMIWff5DJvCioyiCAbDeIbEjkUGi95bV)smG6LrdoMwTCbr6ZdE)LyafgACHJdPdPfegQ4koRIbFkgj(YMd2ay4BtAkcxIMbpiGqam04AsUfKwHgJeFoEed8sup0GMi4P085bV)s4Qxgn4yoKoKTXtDalUraA6j2bMMEsXzvSNBHWHPiA6577OXNCmp1aiiU4PEdkmI7PG889D04t8uAE3ZXmPXtCPXLt8eb7P0CpJk49xc3tbHuoKwqyOIR4Skg8PyK4lBoydycIltEdkmkAg8aXaVeflCykIMQxgn4yTOPGHvSWHPiAQO2BrtbdRyHdtr0urE3yfhIqPGcVXbm8stbdRyHdtr0uXflmYH0H0ccdvCfNvXGpfJeFzZbBam8TjnfHlrZGheqiagACnj3cIdPdzB8ClIknU4PfcmSxIbaA6jf)EQtrIVNiyp1GOXN45yM04PgaW63t9guyKNyuewf7jNvXG7PyK4lkhslimuXvCwfd(ums8LnhSbmW6FYBqHrrh0ma(ums8f(aOIMbpGCyY5ngn4TIGMcgwXPiXFIGN7OXNOO2DiTGWqfxXzvm4tXiXx2CWgcsEF2nUCIMrZGhig4LOeK8(SBC5envVmAWXAbnnfmSICoQSk8PGK3vK3nwXHyKPvl00uWWkY5OYQWNcsExrE3yfhIqttbdRmE4fMvHRWOiMWq1MbecGHgxkJhEHzv4kY7gR440kGqam04sz8WlmRcxrE3yfhIqfjCWXH0H0ccdvCfNvXGpfJeFzZbBatqCzYBqHrrZGhig4LOyHdtr0u9YObhRfnfmSIfomfrtf1ElOPPGHvSWHPiAQiVBSIdX4agEBlEPPGHvSWHPiAQ4IfgPvlnfmSIlisF0)(jkQDTAJqmWlr1nUCYebpLMpp49xcx9YObhdhhslimuXvCwfd(ums8LnhSrOXy1eWIBKIvXrZGhqtbdRKheuXctPHQWorrT3kcAkyyfxqK(O)9tuu7T47haMIrIVWvHgJvtalUrkwfJhOCiTGWqfxXzvm4tXiXx2CWgawCJuSkEsJaIdPfegQ4koRIbFkgj(YMd2agy9p5nOWOO7i8zv8aOIoOza8PyK4l8bqfndEa5WKZBmAWDiTGWqfxXzvm4tXiXx2CWgWaR)jVbfgfDhHpRIhav0m4bDe(V)suymUyv44jYCiDiBJNAaeex8uVbfg5jJ7jII4zhH)7VepHzaWjkhslimuXvCwfd(ums8LnhSbmbXLjVbfgfDhHpRIha1sh)t4muTGaUhckCXqrbQHudbfUJYsFSrkwfZx6BH(oIihZZ26PfegQ8eW4cx5qU0bmUWxBV05Skg8PyK4lRTxqaQ12l9xgn4yR2x6bctoHzlDO9mcpfwyeRI9uRwpfd8suCbr6ZdE)Lya1lJgCmpB5zaHayOXLIlisFEW7VedOiVBSI7je9e3EIxpJdyEQvRNyirbdS(N8guyKI8UXkUNqCGNXbmp1Q1tXaVeLXdVWSkC1lJgCmpB5jgsuWaR)jVbfgPiVBSI7je9eApdieadnUugp8cZQWvK3nwX9CtpPPGHvgp8cZQWvyuetyOYtC8SLNbecGHgxkJhEHzv4kY7gR4EcrpBRNT8eApJWtXaVefxqK(8G3Fjgq9YObhZtTA9umWlrXfePpp49xIbuVmAWX8SLNCbr6ZdE)LyafgAC5joEIJNT8eApPPGHvJzf2mMIlkUyHrEcrpHQTEQvRNMgDctUIfxhrXN7i5LWmGIy1ipXZapXTNA16jnfmScy4Btofj(kQDp1Q1Zi8KMcgwrdqimafxuu7EIJNT8mcpPPGHvCks8Ni45oA8jkQ9LUfegQw6WaR)jVbfgTKfeW9A7L(lJgCSv7l9aHjNWSLUyGxIY4HxywfU6LrdoMNT8mGqam04sbm8TjnfHlkY7gR4EIhphYZwEcTNCbr6ZdE)LyafgAC5PwTEgHNIbEjkUGi95bV)smG6LrdoMN44zlpH2Zi8umWlrXchMIOP6LrdoMNA16zeEstbdRyHdtr0urT7zlpJWZacbWqJlflCykIMkQDpXzPBbHHQLUXdVWSk8LSGquwBV0Fz0GJTAFPhim5eMT0fd8suh8(lXatAGXf1lJgCmpB5j0Ekg4LO6gxozIGNsZNh8(lHREz0GJ5zlpPPGHvDJlNmrWtP5ZdE)LWvu7E2YZUDaxiOUNq0ZiBip1Q1Zi8umWlr1nUCYebpLMpp49xcx9YObhZtC8SLNq7zeEcTNCbr6ZdE)Lyaf1UNT8umWlrXfePpp49xIbuVmAWX8ehp1Q1ttJoHjxvMqrmWSXiDuPPIy1iph4zu8SLN0uWWQXScBgtXffxSWipHONq1wpXzPBbHHQL(bV)smWKgyCzjli0212l9xgn4yR2x6bctoHzlDXaVefxqK(O)9tuVmAWX8SLNq7jXyyZJ)lrzyyCvarvINq0ZO4PwTEsmg284)sugggxXkpXJNrAipXXZwEcTNr4PyGxIItrI)ebp3rJpr9YObhZtTA9KMcgwXPiXFIGN7OXNOO29uRwp72bCHG6EINbE2226jolDlimuT05cI0h9VFYswqisRTx6VmAWXwTV0deMCcZw6IbEjkatdtXWMDlUBtbjVREz0GJ5zlpH2tIXWMh)xIYWW4QaIQepHONrXtTA9KymS5X)LOmmmUIvEIhpJ0qEIZs3ccdvlDatdtXWMDlUBtbjVVKfeIS12l9xgn4yR2x6bctoHzlDAkyyfxqK(O)9tuu7E2Yt((bGPyK4lCvOXy1eWIBKIvXEcrpXTNT8eApnn6eMCfWW3M8guyKIy1ipXRN0uWWkGHVn5nOWifxSWipXXti6jUJmpB5j0EstbdR6gxozIGNsZNh8(lHRO29SLNr4PyGxIItrI)ebp3rJpr9YObhZtTA9KMcgwXPiXFIGN7OXNOO29eNLUfegQw6awCJuSkEsJaYswqqJzT9s)Lrdo2Q9LEGWKty2shAp57haMIrIVWvHgJvtalUrkwf7jE8ekp1Q1ttJoHjxjpiOIfMsdvHDIIy1ipXZapJINT8mcpfd8suCks8Ni45oA8jQxgn4yE2YttJoHjxbm8TjVbfgPiwnYti6juEIJNT800OtyYvadFBYBqHrkIvJ8eVEstbdRag(2K3GcJuCXcJ8eIEcTNrjY8CtpJIN41ttJoHjxjpiOIfMsdvHDIIy1ipXRN89datXiXx4QqJXQjGf3ifRI9ehpB5j0EgHNIbEjkofj(te8Chn(e1lJgCmp1Q1Zi8edjkyG1)K3GcJuKdtoVXOb3tTA9KlisFEW7VedOO29ehpB5j0EgHNIbEjQUXLtMi4P085bV)s4Qxgn4yEQvRN0uWWQUXLtMi4P085bV)s4kQDp1Q1ZacbWqJlfWW3M0ueUOiVBSI7jE8CipB5z3oGleu3t8mWtCbU9CtpJYqEIxpfd8subdaMsZNsdvHDI6LrdoMN4S0TGWq1s)grA0Wu2OVKfe0axBV0Fz0GJTAFPhim5eMT0JWtAkyyfNIe)jcEUJgFIIA3ZwEkg4LO6gxozIGNsZNh8(lHREz0GJ5zlpH2tAkyyv34Yjte8uA(8G3FjCf1UNA16zaHayOXLcy4BtAkcxuK3nwX9epEoKNT8SBhWfcQ7jEg4jUa3EUPNrzipXRNIbEjQGbatP5tPHQWor9YObhZtTA9KVFaykgj(cxfAmwnbS4gPyvSNq0tC7zlpH2ttJoHjxbm8TjVbfgPiwnYt86jnfmScy4BtEdkmsXflmYti6jUJmpXXZwEstbdR4cI0h9VFIIA3ZwEgqiagACPag(2KMIWff5DJvCpH4apJdyEIZs3ccdvl9BePzYBqHrlzbbCXA7L(lJgCSv7l9aHjNWSLEeEkg4LO6gxozIGNsZNh8(lHREz0GJ5zlpJWtO900OtyYvS46ik(ChjVeMbueRg5jE8e3E2YtAkyyLXdVWSkCf1UN44zlpH2tAkyyfxqK(O)9tuu7EQvRND7aUqqDpXZapXfd55MEgLH8eVEkg4LOcgamLMpLgQc7e1lJgCmp1Q1Zi8eAp5cI0Nh8(lXakQDpB5PyGxIIlisFEW7VedOEz0GJ5joE2YZJR7pihBgqDAtMGxXsJNd7PW63ZH9mGqam04sXfePpp49xIbuK3nwX9CypHksd5jE9egGqepH2tO9846(dYXMbuN2Kj4vS045WEkS(9CypdieadnUuCbr6ZdE)Lyaf5DJvCpXXtnKNqfPH8ehpXZapJYqEIxpH2tO8CtpH2ttJoHjx9qdAIGNsZNh8(lXaCfXQrEINbEIBpXXtC8eNLUfegQw63isZK3GcJwYccqn0A7L(lJgCSv7l9aHjNWSLUyGxIItrI)ebp3rJpr9YObhZZwEgHN0uWWkofj(te8Chn(ef1UNT8mGqam04sbm8TjnfHlkY7gR4EcXbEghW8SLNq7zeEkg4LO4cI0Nh8(lXaQxgn4yE2YZi8eMr(8G3FjgqrT7PwTEkg4LO4cI0Nh8(lXaQxgn4yE2YZi8KlisFEW7VedOO29eNLUfegQw63isZK3GcJwYccqb1A7L(lJgCSv7l9aHjNWSLoxqK(8G3FjgqrT7zlpfd8suCbr6ZdE)Lya1lJgCmpB5j0EAA0jm5kwCDefFUJKxcZakIvJ8eIEIBp1Q1Zi8KMcgwbm8TjNIeFf1UNT8KMcgwrdqimafxuu7EIZs3ccdvlDalUrkwfpPrazjliafUxBV0Fz0GJTAFPhim5eMT0H2tAkyyfxqK(O)9tuK3nwX9eIEcLckpXRNXbmpXRN0uWWkUGi9r)7NO4Ifg5PwTEstbdR4cI0h9VFIIA3ZwEstbdR6gxozIGNsZNh8(lHRO29eNLUfegQw6awCJuSkEsJaYswqaQOS2EP)YObhB1(spqyYjmBPlg4LOyHdtr0u9YObhZZwEkg4LO6gxozIGNsZNh8(lHREz0GJ5zlpPPGHvSWHPiAQO29SLN0uWWQUXLtMi4P085bV)s4kQ9LUfegQw6WeexM8guy0swqaQ2U2EP)YObhB1(spqyYjmBPttbdRmE4fMvHRO2x6wqyOAPdm8TjnfHllzbbOI0A7L(lJgCSv7lDlimuT0Hbw)tEdkmAPhim5eMT0jhMCEJrdUNT80ccd)pF9o7CpXJNq5zlpPPGHvCks8Ni45oA8jkQ9LEqZa4tXiXx4lia1swqaQiBT9s)Lrdo2Q9LEGWKty2sxmWlrXfePpp49xIbuVmAWX8SLNbecGHgxtYTG4zlpPPGHvCks8Ni45oA8jkQDpB5j0EECD)b5yZaQtBYe8kwA8Cypfw)EoSNbecGHgxkUGi95bV)smGI8UXkUNd7jurAipXRNWaeI4j0EcTNhx3Fqo2mG60MmbVILgph2tH1VNd7zaHayOXLIlisFEW7VedOiVBSI7joEQH8eQinKN44je9mkd5jE9eApHYZn9eApnn6eMC1dnOjcEknFEW7VedWveRg5jEg4jU9ehpXXtTA9eApHsbvK5jE9eAppUU)GCSza1PnzcEflnEoSNcRFpXXZH9mGqam04sXfePpp49xIbuK3nwX9CypHksd5jE9egGqepH2tO9ekfurMN41tO9846(dYXMbuN2Kj4vS045WEkS(9ehph2ZacbWqJlfxqK(8G3FjgqrE3yf3tC8ud5jurAipXXtC8eIEcTNhx3Fqo2mG60MmbVILgph2tH1VNd7zaHayOXLIlisFEW7VedOiVBSI75WEcvKgYt86jmaHiEcTNq75X19hKJndOoTjtWRyPXZH9uy975WEgqiagACP4cI0Nh8(lXakY7gR4EIJNAipHksd5joEIJN4S0TGWq1shy4BtAkcxwYccqPXS2EP)YObhB1(spqyYjmBPhHNIbEjkUGi95bV)smG6LrdoMNT8mGqam04AsUfepB5jnfmSItrI)ebp3rJprrT7zlpH2ZJR7pihBgqDAtMGxXsJNd7PW63ZH9mGqam04sbZiFEW7VedOiVBSI75WEcvKgYt86jmaHiEcTNq75X19hKJndOoTjtWRyPXZH9uy975WEgqiagACPGzKpp49xIbuK3nwX9ehp1qEcvKgYtC8eIEgLH8eVEcTNq55MEcTNMgDctU6Hg0ebpLMpp49xIb4kIvJ8epd8e3EIJN44PwTEcTNqPGkY8eVEcTNhx3Fqo2mG60MmbVILgph2tH1VN445WEgqiagACPGzKpp49xIbuK3nwX9CypHksd5jE9egGqepH2tO9ekfurMN41tO9846(dYXMbuN2Kj4vS045WEkS(9ehph2ZacbWqJlfmJ85bV)smGI8UXkUN44PgYtOI0qEIJN44je9eAppUU)GCSza1PnzcEflnEoSNcRFph2ZacbWqJlfmJ85bV)smGI8UXkUNd7jurAipXRNWaeI4j0EcTNhx3Fqo2mG60MmbVILgph2tH1VNd7zaHayOXLcMr(8G3FjgqrE3yf3tC8ud5jurAipXXtC8eNLUfegQw6adFBstr4YswqaknW12l9xgn4yR2x6bctoHzlDAkyyfNIe)jcEUJgFIIAFPBbHHQLoGf3ifRIN0iGSKfeGcxS2EP)YObhB1(spqyYjmBPhqiagACnj3cINT8mcpfd8suDJlNmrWtP5ZdE)LWvVmAWXw6wqyOAPdm8TjnfHllzbbCp0A7L(lJgCSv7l9aHjNWSLUyGxIIfomfrt1lJgCmpB5zeEcTND7aUqqDpXJNAmrYZwEgqiagACPag(2KMIWff5DJvCpH4aphYtC8SLNq7zeEkg4LO4cI0Nh8(lXaQxgn4yEQvRNCbr6ZdE)LyafgAC5jolDlimuT0zHdtr0CjliGBOwBV0Fz0GJTAFPhim5eMT0dieadnUMKBbXZwEgAms85EIhpfd8sup0GMi4P085bV)s4Qxgn4ylDlimuT0bg(2KMIWLLSGaUX9A7L(lJgCSv7l9aHjNWSLUyGxIIfomfrt1lJgCmpB5jnfmSIfomfrtf1UNT8KMcgwXchMIOPI8UXkUNq0tOuq5jE9moG5jE9KMcgwXchMIOPIlwy0s3ccdvlDycIltEdkmAjliG7OS2EP)YObhB1(spqyYjmBPhqiagACnj3cYs3ccdvlDGHVnPPiCzjliG72U2EP)YObhB1(s3ccdvlDyG1)K3GcJw6bctoHzlDYHjN3y0G7zlpJWtAkyyfNIe)jcEUJgFIIAFPh0ma(ums8f(ccqTKfeWDKwBV0Fz0GJTAFPhim5eMT0fd8sucsEF2nUCIMQxgn4yE2YtO9KMcgwrohvwf(uqY7kY7gR4EcrpJmp1Q1tO9KMcgwrohvwf(uqY7kY7gR4EcrpH2tAkyyLXdVWSkCfgfXegQ8CtpdieadnUugp8cZQWvK3nwX9ehpB5zaHayOXLY4HxywfUI8UXkUNq0tOIKN44jolDlimuT0fK8(SBC5enxYcc4oYwBV0Fz0GJTAFPhim5eMT0fd8suSWHPiAQEz0GJ5zlpPPGHvSWHPiAQO29SLNq7jnfmSIfomfrtf5DJvCpHONXbmpXRNT1t86jnfmSIfomfrtfxSWip1Q1tAkyyfxqK(O)9tuu7EQvRNr4PyGxIQBC5KjcEknFEW7VeU6LrdoMN4S0TGWq1shMG4YK3GcJwYcc4wJzT9s)Lrdo2Q9LEGWKty2sNMcgwjpiOIfMsdvHDIIA3ZwEgHN0uWWkUGi9r)7NOO29SLN89datXiXx4QqJXQjGf3ifRI9epEc1s3ccdvl9qJXQjGf3ifRIxYcc4wdCT9s3ccdvlDalUrkwfpPrazP)YObhB1(swqa34I12l9xgn4yR2x6wqyOAPddS(N8guy0spOza8PyK4l8feGAPhim5eMT0jhMCEJrd(sVJWNvXlDOwYccrzO12l9xgn4yR2x6bctoHzl9oc)3FjkmgxSkCpXJNr2s3ccdvlDyG1)K3GcJw6De(SkEPd1swqikqT2EP3r4ZQ4LoulDlimuT0HjiUm5nOWOL(lJgCSv7lzjlDd912lia1A7L(lJgCSv7l9aHjNWSLUyGxIIlisF0)(jQxgn4ylDlimuT05cI0h9VFYswqa3RTx6VmAWXwTV0TGWq1shgy9p5nOWOLEGWKty2sNCyY5ngn4E2YtO9KVFaykgj(cxfAmwnbS4gPyvSNq0tO9msEoSNr4PyGxIsqY7ZUXLt0u9YObhZtC8uRwpJWtXaVefxqK(8G3Fjgq9YObhZZwEcTNWmYNh8(lXakY7gR4EIhpH2tOARN41t((bGzJXL7joEQvRNbecGHgxkyg5ZdE)Lyaf5DJvCpHONq7jUBRNd7juT1t86jF)aWSX4Y9ehpXXtC8SLNq7zeEkg4LO4cI0Nh8(lXaQxgn4yEQvRNCbr6ZdE)LyafgAC5PwTEY3pamfJeFHRcngRMawCJuSk2ZbEgfpB5jnfmSAmRWMXuCrXflmYti6juT1tCw6bndGpfJeFHVGaulzbHOS2EP)YObhB1(spqyYjmBPlg4LOmE4fMvHREz0GJ5zlpH2tXaVefxqK(8G3Fjgq9YObhZZwEYfePpp49xIbuyOXLNT8mGqam04sXfePpp49xIbuK3nwX9epEcvK8uRwpJWtXaVefxqK(8G3Fjgq9YObhZtC8SLNq7zeEkg4LOyHdtr0u9YObhZtTA9mcpPPGHvSWHPiAQO29SLNr4zaHayOXLIfomfrtf1UN4S0TGWq1s34Hxywf(swqOTRTx6VmAWXwTV0deMCcZw6IbEjkatdtXWMDlUBtbjVREz0GJT0TGWq1shW0WumSz3I72uqY7lzbHiT2EP)YObhB1(spqyYjmBPhHNIbEjQUXLtMi4P085bV)s4Qxgn4yEQvRN0uWWkUGi9r)7NOO29uRwp72bCHG6EINbEcTNqn0qEoSNT1t86jF)aWums8fUk0ySAcyXnsXQypXXtTA9KMcgw1nUCYebpLMpp49xcxrT7PwTEY3pamfJeFHRcngRMawCJuSk2t84zuw6wqyOAPFJinAykB0xYccr2A7L(lJgCSv7l9aHjNWSLonfmSIlisF0)(jkY7gR4EcrpJIN41Z4aMN41tAkyyfxqK(O)9tuCXcJw6wqyOAPhAmwnbS4gPyv8swqqJzT9s)Lrdo2Q9LEGWKty2sNMcgwbm8TjNIeFf1UNT8KVFaykgj(cxfAmwnbS4gPyvSNq0Z26zlpH2Zi8umWlrXfePpp49xIbuVmAWX8uRwp5cI0Nh8(lXakm04YtC8SLNyirbdS(N8guyKsyHrSkEPBbHHQLoWW3M0ueUSKfe0axBV0Fz0GJTAFPhim5eMT057haMIrIVWvHgJvtalUrkwf7je9STE2YZi8KMcgwz8WlmRcxrTV0TGWq1sNfomfrZLSGaUyT9s)Lrdo2Q9LEGWKty2sNVFaykgj(cxfAmwnbS4gPyvSNq0Z26zlpPPGHvSWHPiAQO29SLNr4jnfmSY4HxywfUIAFPBbHHQLombXLjVbfgTKfeGAO12l9xgn4yR2x6bctoHzlDXaVe1bV)smWKgyCr9YObhZZwEY3pamfJeFHRcngRMawCJuSk2ti6zB9SLNq7zeEkg4LO4cI0Nh8(lXaQxgn4yEQvRNCbr6ZdE)LyafgAC5jolDlimuT0p49xIbM0aJllzbbOGAT9s)Lrdo2Q9LEGWKty2sxmWlrz8WlmRcx9YObhBPBbHHQLoWW3M036lzbbOW9A7LUfegQw6HgJvtalUrkwfV0Fz0GJTAFjliavuwBV0Fz0GJTAFPhim5eMT0fd8sugp8cZQWvVmAWXw6wqyOAPdm8TjnfHll9ocFwfV0HAjliavBxBV0Fz0GJTAFPBbHHQLomW6FYBqHrl9GMbWNIrIVWxqaQLEGWKty2sNCyY5ngn4l9ocFwfV0HAjliavKwBV07i8zv8shQLUfegQw6WeexM8guy0s)Lrdo2Q9LSKLo2HnkGS2EbbOwBV0Fz0GJTOx6bctoHzlDtJoHjxzv4CHyGj5Cuzv4Qxgn4ylDlimuT0PbiegGIllzbbCV2EP)YObhB1(spqyYjmBPFCD)b5yZaQtBYe8kwA8Cypfw)EcrpJYqEQvRNWmYNh8(lXakQDp1Q1tUGi95bV)smGIAFPBbHHQL(osyOAjlieL12lDlimuT0hZkSjV5gzP)YObhB1(swqOTRTx6VmAWXwTV0deMCcZw6IbEjkbjVp7gxort1lJgCmpB5jnfmSICoQSk8PGK3vK3nwX9eIEI7LUfegQw6csEF2nUCIMlzbHiT2EP)YObhB1(spqyYjmBPhHNIbEjkUGi95bV)smG6Lrdo2s3ccdvlDyg5ZdE)LyGLSGqKT2EP)YObhB1(spqyYjmBPlg4LO4cI0Nh8(lXaQxgn4yE2YtO9mcpfd8suSWHPiAQEz0GJ5PwTEgHN0uWWkw4Wuenvu7E2YZi8mGqam04sXchMIOPIA3tC8SLNq7zeEkg4LOmE4fMvHREz0GJ5PwTEgHNbecGHgxkJhEHzv4kQDpXzPBbHHQLoxqK(8G3FjgyjliOXS2EPBbHHQLof)tM8oFP)YObhB1(swqqdCT9s)Lrdo2Q9LEGWKty2spcpfd8sugp8cZQWvVmAWX8uRwpPPGHvgp8cZQWvu7EQvRNbecGHgxkJhEHzv4kY7gR4EIhpJ0qlDlimuT0Pbie2eMIO5swqaxS2EP)YObhB1(spqyYjmBPhHNIbEjkJhEHzv4Qxgn4yEQvRN0uWWkJhEHzv4kQ9LUfegQw60NWpzeRIxYccqn0A7L(lJgCSv7l9aHjNWSLEeEkg4LOmE4fMvHREz0GJ5PwTEstbdRmE4fMvHRO29uRwpdieadnUugp8cZQWvK3nwX9epEgPHw6wqyOAPdZiNgGqylzbbOGAT9s)Lrdo2Q9LEGWKty2spcpfd8sugp8cZQWvVmAWX8uRwpPPGHvgp8cZQWvu7EQvRNbecGHgxkJhEHzv4kY7gR4EIhpJ0qlDlimuT0TkCUqmWmyaWswqakCV2EP)YObhB1(spqyYjmBPZfePpp49xIbuu7E2YtAkyyvWaGjGf3ifRIvK3nwX9epd8udCPBbHHQL(18te8uA(KlisFjliavuwBV0TGWq1sVF5iYs)Lrdo2Q9LSGauTDT9s)Lrdo2Q9LEGWKty2s3ccd)pF9o7CpXJN42ZwEcTN89datXiXx4QqJXQjGf3ifRI9epEIBp1Q1t((bGPyK4lCfWW3M036EIhpXTN4S0TGWq1sNqvtlimunbmUS0bmUmlR)LUH(swqaQiT2EP)YObhB1(s3ccdvlDcvnTGWq1eW4YshW4YSS(x6Cwfd(ums8LLSKL(o5buN2K12lia1A7L(lJgCSv7lzbbCV2EP)YObhB1(swqikRTx6VmAWXwTVKfeA7A7L(lJgCSv7lzbHiT2EPBbHHQLUGK3NDJlNO5s)Lrdo2Q9LSGqKT2EP)YObhB1(spqyYjmBPhHNIbEjQDcRBG5bV)smaJlQxgn4ylDlimuT0VrKM5bV)smWswqqJzT9s)Lrdo2Q9LEGWKty2sxmWlrXfePp6F)e1lJgCmpB5j0Esmg284)sugggxfquL4je9mkEQvRNeJHnp(VeLHHXvSYt84zKgYtCw6wqyOAPZfePp6F)KLSGGg4A7L(lJgCSv7l9aHjNWSLEeEkg4LO4cI0Nh8(lXaQxgn4ylDlimuT0HzKpp49xIbwYcc4I12l9xgn4yR2x6bctoHzlDXaVefxqK(8G3Fjgq9YObhBPBbHHQLoxqK(8G3Fjgyjlia1qRTx6wqyOAPVJegQw6VmAWXwTVKfeGcQ12l9xgn4yR2x6bctoHzlDXaVe1bV)smWKgyCr9YObhBPBbHHQL(bV)smWKgyCzjliafUxBV0Fz0GJTAFPhim5eMT0JWtXaVe1bV)smWKgyCr9YObhZZwEY3pamfJeFHRcngRMawCJuSk2ti6zuw6wqyOAPdm8TjnfHllzbbOIYA7L(lJgCSv7l9aHjNWSLoF)aWums8fUk0ySAcyXnsXQypXJN4EPBbHHQLEOXy1eWIBKIvXlzjlzPBusdIS01zDkGjmuTLjgSSKLSwa]] )


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
